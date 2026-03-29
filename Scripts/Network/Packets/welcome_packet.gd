class_name WelcomePacket extends Packet

var client_id: int


func _init(_client_id: int) -> void:
	type = Packet.WELCOME
	client_id = _client_id


func serialize() -> PackedByteArray:
	var buf = PackedByteArray()
	buf.resize(5)
	buf[0] = type
	buf.encode_u32(1, client_id)
	return buf


static func deserialize(data: PackedByteArray) -> WelcomePacket:
	var _client_id = data.decode_u32(1)
	return WelcomePacket.new(_client_id)
