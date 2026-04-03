class_name TakeCookiePacket extends Packet


var peer_id: int
var cookie_id: int
var amount: int


func _init(_peer_id: int, _cookie_id: int, _amount: int = 0) -> void:
	type = Packet.TAKE_COOKIE
	peer_id = _peer_id
	cookie_id = _cookie_id
	amount = _amount


func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(1 + 4 + 4 + 4)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_u32(5, cookie_id)
	buf.encode_u32(9, amount)
	return buf


static func deserialize(data: PackedByteArray) -> TakeCookiePacket:
	var _peer_id := data.decode_u32(1)
	var _cookie_id := data.decode_u32(5)
	var _amount := 0
	if data.size() >= 13:
		_amount = data.decode_u32(9)
	return TakeCookiePacket.new(_peer_id, _cookie_id, _amount)
