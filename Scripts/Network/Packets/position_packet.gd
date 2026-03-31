class_name PositionPacket extends Packet

var peer_id: int
var x: float
var y: float
var look_angle: float
var health: int


func _init(_x: float, _y: float, _look: float = 0.0, _health: int = 10, _peer_id: int = 0) -> void:
	type = Packet.POSITION
	x = _x
	y = _y
	look_angle = _look
	health = _health
	peer_id = _peer_id


func serialize() -> PackedByteArray:
	var buf = PackedByteArray()
	buf.resize(21)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_float(5, x)
	buf.encode_float(9, y)
	buf.encode_float(13, look_angle)
	buf.encode_u32(17, health)
	return buf


static func deserialize(data: PackedByteArray) -> PositionPacket:
	var _peer_id = data.decode_u32(1)
	var _x = data.decode_float(5)
	var _y = data.decode_float(9)
	var _look = data.decode_float(13)
	var _health = data.decode_u32(17)
	return PositionPacket.new(_x, _y, _look, _health, _peer_id)
