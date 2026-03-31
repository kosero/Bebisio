package packet

import (
	"encoding/binary"
	"unsafe"
)

const (
	POSITION    byte = 0x01
	JOIN        byte = 0x02
	TAKE_COOKIE byte = 0x03
	TAKE_AMMO   byte = 0x04
	SHOOT       byte = 0x05
	SPAWN_ITEM  byte = 0x06
	RESPAWN     byte = 0x07

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

func SerializeSpawnItem(itemType byte, itemID uint32, progress float32) []byte {
	buf := make([]byte, 10)
	buf[0] = SPAWN_ITEM
	buf[1] = itemType
	binary.LittleEndian.PutUint32(buf[2:6], itemID)
	binary.LittleEndian.PutUint32(buf[6:10], float32tobits(progress))
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

func SerializeTakeAmmo(peerID uint32, itemID uint32, ammo uint32) []byte {
	buf := make([]byte, 13)
	buf[0] = TAKE_AMMO
	binary.LittleEndian.PutUint32(buf[1:5], peerID)
	binary.LittleEndian.PutUint32(buf[5:9], itemID)
	binary.LittleEndian.PutUint32(buf[9:13], ammo)
	return buf
}

func ParseShoot(data []byte) (peerID uint32, ok bool) {
	if len(data) < 5 {
		return 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	return peerID, true
}

func ParseRespawn(data []byte) (peerID uint32, ok bool) {
	if len(data) < 5 {
		return 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	return peerID, true
}

func ParseJoin(data []byte) (peerID uint32, name string, ok bool) {
	if len(data) < 10 {
		return 0, "", false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	nameLen := binary.LittleEndian.Uint32(data[5:9])
	if len(data) < int(9+nameLen) {
		return 0, "", false
	}
	name = string(data[9 : 9+nameLen])
	return peerID, name, true
}

func SerializeJoin(peerID uint32, name string) []byte {
	nameBytes := []byte(name)
	buf := make([]byte, 1+4+4+len(nameBytes))
	buf[0] = JOIN
	binary.LittleEndian.PutUint32(buf[1:5], peerID)
	binary.LittleEndian.PutUint32(buf[5:9], uint32(len(nameBytes)))
	copy(buf[9:], nameBytes)
	return buf
}

func ParsePosition(data []byte) (peerID, health uint32, x, y, look float32, ok bool) {
	if len(data) < 21 {
		return 0, 0, 0, 0, 0, false
	}
	peerID = binary.LittleEndian.Uint32(data[1:5])
	x = float32frombits(binary.LittleEndian.Uint32(data[5:9]))
	y = float32frombits(binary.LittleEndian.Uint32(data[9:13]))
	look = float32frombits(binary.LittleEndian.Uint32(data[13:17]))
	health = binary.LittleEndian.Uint32(data[17:21])
	return peerID, health, x, y, look, true
}

func SerializePosition(peerID, health uint32, x, y, look float32) []byte {
	buf := make([]byte, 21)
	buf[0] = POSITION
	binary.LittleEndian.PutUint32(buf[1:5], peerID)
	binary.LittleEndian.PutUint32(buf[5:9], float32tobits(x))
	binary.LittleEndian.PutUint32(buf[9:13], float32tobits(y))
	binary.LittleEndian.PutUint32(buf[13:17], float32tobits(look))
	binary.LittleEndian.PutUint32(buf[17:21], health)
	return buf
}

func float32frombits(b uint32) float32 {
	return *(*float32)(unsafe.Pointer(&b))
}

func float32tobits(f float32) uint32 {
	return *(*uint32)(unsafe.Pointer(&f))
}
