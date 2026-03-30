class_name TakeCookiePacket extends Packet


var peer_id: int
var cookie_id: int


func _init(_peer_id: int, _cookie_id: int) -> void:
	type = Packet.TAKE_COOKIE
	peer_id = _peer_id
	cookie_id = _cookie_id


func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(1 + 4 + 4)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_u32(5, cookie_id)
	return buf


static func deserialize(data: PackedByteArray) -> TakeCookiePacket:
	var _peer_id := data.decode_u32(1)
	var _cookie_id := data.decode_u32(5)
	return TakeCookiePacket.new(_peer_id, _cookie_id)
