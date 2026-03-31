package main

import (
	"sync"
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
	ID        uint32
	Type      byte
	SpawnerID uint32
}

type GameState struct {
	mu              sync.RWMutex
	players         map[uint32]*Player
	takenCookies    map[uint32]bool
	takenMilks      map[uint32]bool
	spawnerOccupied map[uint32]bool
	activeItems     map[uint32]*SpawnedItem
	nextItemID      uint32
}

func NewGameState() *GameState {
	return &GameState{
		players:         make(map[uint32]*Player),
		takenCookies:    make(map[uint32]bool),
		takenMilks:      make(map[uint32]bool),
		spawnerOccupied: make(map[uint32]bool),
		activeItems:     make(map[uint32]*SpawnedItem),
		nextItemID:      1,
	}
}

func (g *GameState) IsSpawnerOccupied(id uint32) bool {
	g.mu.RLock()
	defer g.mu.RUnlock()
	return g.spawnerOccupied[id]
}

func (g *GameState) RegisterSpawn(itemID uint32, spawnerID uint32, itemType byte) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.spawnerOccupied[spawnerID] = true
	g.activeItems[itemID] = &SpawnedItem{
		ID:        itemID,
		Type:      itemType,
		SpawnerID: spawnerID,
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
		if p.Name != "" { // Only sync players who have finished JOINing
			players = append(players, p)
		}
	}
	
	items := make([]*SpawnedItem, 0, len(g.activeItems))
	for _, item := range g.activeItems {
		items = append(items, item)
	}
	
	return players, items
}

func (g *GameState) CanTakeCookie(cookieID uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.takenCookies[cookieID] {
		return false
	}
	g.takenCookies[cookieID] = true

	if item, ok := g.activeItems[cookieID]; ok {
		g.spawnerOccupied[item.SpawnerID] = false
		delete(g.activeItems, cookieID)
	}
	return true
}

func (g *GameState) CanTakeAmmo(playerID, milkID, amount uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.takenMilks[milkID] {
		return false
	}
	if p, ok := g.players[playerID]; ok {
		p.Ammo += amount
		g.takenMilks[milkID] = true

		if item, ok := g.activeItems[milkID]; ok {
			g.spawnerOccupied[item.SpawnerID] = false
			delete(g.activeItems, milkID)
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
