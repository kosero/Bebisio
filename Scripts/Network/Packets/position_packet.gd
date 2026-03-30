class_name PositionPacket extends Packet

var peer_id: int
var x: float
var y: float


func _init(_x: float, _y: float, _peer_id: int = 0) -> void:
	type = Packet.POSITION
	x = _x
	y = _y
	peer_id = _peer_id


func serialize() -> PackedByteArray:
	var buf = PackedByteArray()
	buf.resize(13)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_float(5, x)
	buf.encode_float(9, y)
	return buf


static func deserialize(data: PackedByteArray) -> PositionPacket:
	var _peer_id = data.decode_u32(1)
	var _x = data.decode_float(5)
	var _y = data.decode_float(9)
	return PositionPacket.new(_x, _y, _peer_id)
