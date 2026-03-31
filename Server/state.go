package main

import (
	"sync"
)

type Player struct {
	ID   uint32
	Name string
	X    float32
	Y    float32
	Ammo uint32
}

type GameState struct {
	mu           sync.RWMutex
	players      map[uint32]*Player
	takenCookies map[uint32]bool
	takenMilks   map[uint32]bool
	nextItemID   uint32
}

func NewGameState() *GameState {
	return &GameState{
		players:      make(map[uint32]*Player),
		takenCookies: make(map[uint32]bool),
		takenMilks:   make(map[uint32]bool),
		nextItemID:   1,
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
		ID:   id,
		Ammo: 0,
	}
}

func (g *GameState) RemovePlayer(id uint32) {
	g.mu.Lock()
	defer g.mu.Unlock()
	delete(g.players, id)
}

func (g *GameState) UpdatePlayerPosition(id uint32, x, y float32) {
	g.mu.Lock()
	defer g.mu.Unlock()

	if p, ok := g.players[id]; ok {
		p.X = x
		p.Y = y
	}
}

func (g *GameState) SetPlayerName(id uint32, name string) {
	g.mu.Lock()
	defer g.mu.Unlock()
	if p, ok := g.players[id]; ok {
		p.Name = name
	}
}

func (g *GameState) CanTakeCookie(cookieID uint32) bool {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.takenCookies[cookieID] {
		return false
	}
	g.takenCookies[cookieID] = true
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
