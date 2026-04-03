class_name DeathPacket extends Packet

var peer_id: int
var name: String

func _init(_peer_id: int, _name: String) -> void:
	type = Packet.DEATH
	peer_id = _peer_id
	name = _name

func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	var name_bytes := name.to_utf8_buffer()
	buf.resize(1 + 4 + 4 + name_bytes.size())
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_u32(5, name_bytes.size())
	for i in name_bytes.size():
		buf[9 + i] = name_bytes[i]
	return buf

static func deserialize(data: PackedByteArray) -> DeathPacket:
	var _peer_id := data.decode_u32(1)
	var _name_size := data.decode_u32(5)
	var _name := data.slice(9, 9 + _name_size).get_string_from_utf8()
	return DeathPacket.new(_peer_id, _name)
