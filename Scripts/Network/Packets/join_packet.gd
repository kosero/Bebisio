class_name JoinPacket extends Packet

var name: String


func _init(_name: String) -> void:
	type = Packet.JOIN
	name = _name


func serialize() -> PackedByteArray:
	var buf = PackedByteArray()
	var name_bytes = name.to_utf8_buffer()
	buf.resize(1 + 4 + name_bytes.size())
	buf[0] = type
	buf.encode_u32(1, name_bytes.size())
	buf.append_array(name_bytes)
	return buf


static func deserialize(data: PackedByteArray) -> JoinPacket:
	var length = data.decode_u32(1)
	return JoinPacket.new(data.slice(5, 5 + length).get_string_from_utf8())
