package main

import (
	"sync"
	"time"
)

type Player struct {
	ID        uint32
	Name      string
	X         float32
	Y         float32
	LookAngle float32
	Health    uint32
	Ammo      uint32
}

type SpawnedItem struct {
	ID       uint32
	Type     byte
	Progress float32
}

type GameState struct {
	mu           sync.RWMutex
	players      map[uint32]*Player
	takenCookies map[uint32]bool
	takenMilks   map[uint32]bool
	activeItems  map[uint32]*SpawnedItem
	nextItemID   uint32
	lastCollect  int64
}

func NewGameState() *GameState {
	return &GameState{
		players:      make(map[uint32]*Player),
		takenCookies: make(map[uint32]bool),
		takenMilks:   make(map[uint32]bool),
		activeItems:  make(map[uint32]*SpawnedItem),
		nextItemID:   1,
	}
}

func (g *GameState) GetItemCount() int {
	g.mu.RLock()
	defer g.mu.RUnlock()
	return len(g.activeItems)
}

func (g *GameState) GetLastCollect() int64 {
	g.mu.RLock()
	defer g.mu.RUnlock()
	return g.lastCollect
}

func (g *GameState) RegisterSpawn(itemID uint32, progress float32, itemType byte) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.activeItems[itemID] = &SpawnedItem{
		ID:       itemID,
		Type:     itemType,
		Progress: progress,
	}
}

func (g *GameState) GenerateItemId() uint32 {
	g.mu.Lock()
	defer g.mu.Unlock()
	id := g.nextItemID
	g.nextItemID++
	return id
}

func (g *GameState) AddPlayer(id uint32) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.players[id] = &Player{
		ID:     id,
		Ammo:   0,
		Health: 10,
	}
}

func (g *GameState) RemovePlayer(id uint32) {
	g.mu.Lock()
	defer g.mu.Unlock()
	delete(g.players, id)
}

func (g *GameState) UpdatePlayerPosition(id, health uint32, x, y, look float32) {
	g.mu.Lock()
	defer g.mu.Unlock()

	if p, ok := g.players[id]; ok {
		p.X = x
		p.Y = y
		p.LookAngle = look
		p.Health = health
	}
}

func (g *GameState) SetPlayerName(id uint32, name string) {
	g.mu.Lock()
	defer g.mu.Unlock()
	if p, ok := g.players[id]; ok {
		p.Name = name
	}
}

func (g *GameState) GetWorldState() ([]*Player, []*SpawnedItem) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	players := make([]*Player, 0, len(g.players))
	for _, p := range g.players {
		if p.Name != "" {
			players = append(players, p)
		}
	}

	items := make([]*SpawnedItem, 0, len(g.activeItems))
	for _, item := range g.activeItems {
		items = append(items, item)
	}

	return players, items
}

func (g *GameState) CanTakeCookie(playerID, cookieID, healthAmount uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.takenCookies[cookieID] {
		return false
	}

	if p, ok := g.players[playerID]; ok {
		p.Health += healthAmount
		if p.Health > 10 {
			p.Health = 10
		}
		g.takenCookies[cookieID] = true

		if _, ok := g.activeItems[cookieID]; ok {
			delete(g.activeItems, cookieID)
			g.lastCollect = time.Now().Unix()
		}
		return true
	}
	return false
}

func (g *GameState) CanTakeAmmo(playerID, milkID, _ uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.takenMilks[milkID] {
		return false
	}
	if p, ok := g.players[playerID]; ok {
		p.Ammo += 12
		g.takenMilks[milkID] = true

		if _, ok := g.activeItems[milkID]; ok {
			delete(g.activeItems, milkID)
			g.lastCollect = time.Now().Unix()
		}
		return true
	}
	return false
}

func (g *GameState) CanShoot(playerID uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if p, ok := g.players[uint32(playerID)]; ok {
		if p.Ammo > 0 {
			p.Ammo--
			return true
		}
	}
	return false
}

func (g *GameState) ResetPlayer(playerID uint32) {
	g.mu.Lock()
	defer g.mu.Unlock()
	if p, ok := g.players[playerID]; ok {
		p.Ammo = 0
		p.Health = 10
	}
}
