class_name PositionPacket extends Packet

var x: float
var y: float


func _init(_x: float, _y: float) -> void:
	type = Packet.POSITION
	x = _x
	y = _y


func serialize() -> PackedByteArray:
	var buf = PackedByteArray()
	buf.append(type)
	buf.append_array(var_to_bytes(x))
	buf.append_array(var_to_bytes(y))
	return buf


static func deserialize(data: PackedByteArray) -> PositionPacket:
	var _x = bytes_to_var(data.slice(1, 5))
	var _y = bytes_to_var(data.slice(5, 9))
	return PositionPacket.new(_x, _y)
