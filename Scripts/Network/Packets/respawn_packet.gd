class_name RespawnPacket extends Packet

var peer_id: int

func _init(_peer_id: int) -> void:
	type = Packet.RESPAWN
	peer_id = _peer_id

func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(5)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	return buf

static func deserialize(data: PackedByteArray) -> RespawnPacket:
	var _peer_id := data.decode_u32(1)
	return RespawnPacket.new(_peer_id)
