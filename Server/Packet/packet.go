package packet

import (
	"encoding/binary"
)

const (
	POSITION    byte = 0x01
	JOIN        byte = 0x02
	TAKE_COOKIE byte = 0x03
	TAKE_AMMO   byte = 0x04
	SHOOT       byte = 0x05
	SPAWN_ITEM  byte = 0x06

	WELCOME byte = 0x10
	GOODBYE byte = 0x11
)

func GetType(data []byte) byte {
	if len(data) == 0 {
		return 0
	}
	return data[0]
}

func SerializeGWelcome(clientID uint32) []byte {
	buf := make([]byte, 5)
	buf[0] = WELCOME
	binary.LittleEndian.PutUint32(buf[1:5], clientID)
	return buf
}

func SerializeGoodbye(clientID uint32) []byte {
	buf := make([]byte, 5)
	buf[0] = GOODBYE
	binary.LittleEndian.PutUint32(buf[1:5], clientID)
	return buf
}

func SerializeSpawnItem(itemType byte, itemID uint32, spawnerID uint32) []byte {
	buf := make([]byte, 5)
	buf[0] = SPAWN_ITEM
	buf[1] = itemType
	binary.LittleEndian.PutUint32(buf[2:6], itemID)
	binary.LittleEndian.PutUint32(buf[6:10], spawnerID)
	return buf
}

func GetPeerID(data []byte) uint32 {
	if len(data) < 5 {
		return 0
	}
	return binary.LittleEndian.Uint32(data[1:5])
}

func ParseTakeCookie(data []byte) (peerID uint32, cookieID uint32, ok bool) {
	if len(data) < 9 {
		return 0, 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	cookieID = binary.LittleEndian.Uint32(data[5:9])
	return peerID, cookieID, true
}

func ParseTakeAmmo(data []byte) (peerID uint32, itemID uint32, ammo uint32, ok bool) {
	if len(data) < 13 {
		return 0, 0, 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	itemID = binary.LittleEndian.Uint32(data[5:9])
	ammo = binary.LittleEndian.Uint32(data[9:13])
	return peerID, itemID, ammo, true
}

func ParseShoot(data []byte) (peerID uint32, ok bool) {
	if len(data) < 5 {
		return 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	return peerID, true
}
