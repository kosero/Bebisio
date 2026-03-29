class_name Packet

const POSITION: int = 0x01

var type: int


func serialize() -> PackedByteArray:
	return PackedByteArray()


static func get_type(data: PackedByteArray) -> int:
	return data[0]
