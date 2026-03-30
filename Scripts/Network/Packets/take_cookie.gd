class_name TakeCookiePacket extends Packet


var peer_id: int


func _init(_peer_id: int) -> void:
	type = Packet.TAKE_COOKIE
	peer_id = _peer_id


func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(1 + 4)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	return buf


static func deserialize(data: PackedByteArray) -> TakeCookiePacket:
	var _peer_id := data.decode_u32(1)
	return TakeCookiePacket.new(_peer_id)
