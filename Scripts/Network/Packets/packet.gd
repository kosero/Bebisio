class_name Packet

const POSITION: int = 0x01
const JOIN: int = 0x02
const TAKE_COOKIE: int = 0x03
const TAKE_AMMO: int = 0x04
const SHOOT: int = 0x05
const SPAWN_ITEM: int = 0x06
const RESPAWN: int = 0x07
const DEATH: int = 0x08

const WELCOME: int = 0x10
const GOODBYE: int = 0x11

var type: int


func serialize() -> PackedByteArray:
	return PackedByteArray()


static func get_type(data: PackedByteArray) -> int:
	if data.is_empty():
		return -1
	return data[0]
