class_name Packet

const POSITION: int = 0x01
const JOIN: int = 0x02

const WELCOME: int = 0x10
const GOODBYE: int = 0x11

var type: int


func serialize() -> PackedByteArray:
	return PackedByteArray()


static func get_type(data: PackedByteArray) -> int:
	return data[0]
