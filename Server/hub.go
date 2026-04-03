package main

import (
	"log"
	"math/rand"
	packet "server/Packet"
	"time"
)

type BroadcastMessage struct {
	sender *Client
	data   []byte
}

type Hub struct {
	clients    map[uint32]*Client
	broadcast  chan *BroadcastMessage
	register   chan *Client
	unregister chan *Client
	nextID     uint32
	state      *GameState
}

func NewHub() *Hub {
	return &Hub{
		broadcast:  make(chan *BroadcastMessage),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[uint32]*Client),
		nextID:     1,
		state:      NewGameState(),
	}
}

func (h *Hub) Run() {
	spawnTicker := time.NewTicker(1 * time.Second)
	defer spawnTicker.Stop()

	for {
		select {
		case client := <-h.register:
			client.id = h.nextID
			h.nextID++

			h.clients[client.id] = client
			h.state.AddPlayer(client.id)

			log.Printf("Client %d connected\n", client.id)
			client.send <- packet.SerializeGWelcome(client.id)

		case client := <-h.unregister:
			if _, ok := h.clients[client.id]; ok {
				log.Printf("Client %d disconnected\n", client.id)

				name := h.state.GetPlayerName(client.id)

				h.state.RemovePlayer(client.id)
				delete(h.clients, client.id)
				close(client.send)
				goodbyePkt := packet.SerializeGoodbye(client.id, name)
				for id, c := range h.clients {
					if id != client.id {
						select {
						case c.send <- goodbyePkt:
						default:
							close(c.send)
							delete(h.clients, c.id)
						}
					}
				}
			}
		case message := <-h.broadcast:
			h.routePacket(message)

		case <-spawnTicker.C:
			h.spawnItem()
		}
	}
}

func (h *Hub) spawnItem() {
	if len(h.clients) == 0 {
		return
	}

	if h.state.GetItemCount() >= 5 {
		return
	}

	lastCollect := h.state.GetLastCollect()
	if time.Now().Unix() < lastCollect+2 {
		return
	}

	progress := rand.Float32()
	itemType := byte(rand.Intn(2))
	itemID := h.state.GenerateItemId()

	h.state.RegisterSpawn(itemID, progress, itemType)

	spawnPkt := packet.SerializeSpawnItem(itemType, itemID, progress)

	for targetID, client := range h.clients {
		select {
		case client.send <- spawnPkt:
		default:
			close(client.send)
			delete(h.clients, targetID)
		}
	}

	itemStr := "Milk"
	if itemType == 1 {
		itemStr = "Cookie"
	}
	log.Printf("Server spawned %s (ID: %d) at Progress %.2f\n", itemStr, itemID, progress)
}

func (h *Hub) routePacket(msg *BroadcastMessage) {
	if msg.sender == nil {
		for targetID, client := range h.clients {
			select {
			case client.send <- msg.data:
			default:
				close(client.send)
				delete(h.clients, targetID)
			}
		}
		return
	}

	pktType := packet.GetType(msg.data)
	senderID := msg.sender.id

	isValid := false

	switch pktType {
	case packet.JOIN:
		id, name, ok := packet.ParseJoin(msg.data)
		if ok && id == senderID {
			h.state.SetPlayerName(senderID, name)
			isValid = true
			log.Printf("Player %d joined as %s\n", senderID, name)

			players, items := h.state.GetWorldState()
			for _, p := range players {
				if p.ID != senderID {
					msg.sender.send <- packet.SerializeJoin(p.ID, p.Name)
					msg.sender.send <- packet.SerializePosition(p.ID, p.Health, p.X, p.Y, p.LookAngle)
				}
			}
			for _, item := range items {
				msg.sender.send <- packet.SerializeSpawnItem(item.Type, item.ID, item.Progress)
			}
		}

	case packet.POSITION:
		id, health, x, y, look, ok := packet.ParsePosition(msg.data)
		if ok && id == senderID {
			h.state.UpdatePlayerPosition(senderID, health, x, y, look)
			isValid = true
		}

	case packet.TAKE_COOKIE:
		peerID, cookieID, ok := packet.ParseTakeCookie(msg.data)
		if ok && peerID == senderID && h.state.CanTakeCookie(senderID, cookieID, 2) {
			isValid = true
			log.Printf("Player %d took Cookie %d and healed 2\n", senderID, cookieID)
			msg.data = packet.SerializeTakeCookie(senderID, cookieID, 2)
		} else {
			log.Printf("Player %d failed to take Cookie %d. Rejected.\n", senderID, cookieID)
		}

	case packet.TAKE_AMMO:
		peerID, milkID, _, ok := packet.ParseTakeAmmo(msg.data)
		if ok && peerID == senderID && h.state.CanTakeAmmo(senderID, milkID, 0) {
			isValid = true
			log.Printf("Player %d took 24 ammo from Milk %d\n", senderID, milkID)
			msg.data = packet.SerializeTakeAmmo(peerID, milkID, 24)
		} else {
			log.Printf("Player %d failed to take Ammo from Milk %d. Rejected.\n", senderID, milkID)
		}

	case packet.SHOOT:
		peerID, ok := packet.ParseShoot(msg.data)
		if ok && peerID == senderID && h.state.CanShoot(senderID) {
			isValid = true
			log.Printf("Player %d shot\n", senderID)
		} else {
			log.Printf("Player %d tried to shoot but no ammo. Rejected.\n", senderID)
		}

	case packet.RESPAWN:
		peerID, _, ok := packet.ParseRespawn(msg.data) // Client might send empty name, we use server state
		if ok && peerID == senderID {
			h.state.ResetPlayer(senderID)
			name := h.state.GetPlayerName(senderID)
			isValid = true
			log.Printf("Player %d (%s) respawned\n", senderID, name)
			msg.data = packet.SerializeRespawn(senderID, name)
		}

	case packet.DEATH:
		peerID, _, ok := packet.ParseDeath(msg.data)
		if ok && peerID == senderID {
			name := h.state.GetPlayerName(senderID)
			isValid = true
			log.Printf("Player %d (%s) died\n", senderID, name)
			msg.data = packet.SerializeDeath(senderID, name)
		}

	default:
		log.Printf("Unknown packet type: 0x%X\n", pktType)
	}

	if isValid {
		for targetID, client := range h.clients {
			select {
			case client.send <- msg.data:
			default:
				close(client.send)
				delete(h.clients, targetID)
			}
		}
	}
}
