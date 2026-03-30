class_name JoinPacket extends Packet

var name: String
var peer_id: int


func _init(_name: String, _peer_id) -> void:
	type = Packet.JOIN
	name = _name
	peer_id = _peer_id


func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	var name_bytes := name.to_utf8_buffer()
	buf.resize(1 + 4 + 4 + name_bytes.size())
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_u32(5, name_bytes.size())
	buf.append_array(name_bytes)
	return buf


static func deserialize(data: PackedByteArray) -> JoinPacket:
	var _peer_id  := data.decode_u32(1)
	var _name_size := data.decode_u32(5)
	var _name := data.slice(9, 9 + _name_size).get_string_from_utf8()
	return JoinPacket.new(_name, _peer_id)
