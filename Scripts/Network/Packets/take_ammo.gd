class_name TakeAmmoPacket extends Packet

var peer_id: int
var item_id: int
var ammo: int


func _init(_peer_id: int, _item_id: int, _ammo: int) -> void:
	type = Packet.TAKE_AMMO
	peer_id = _peer_id
	item_id = _item_id
	ammo = _ammo


func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(1 + 4 + 4 + 4)
	buf[0] = type
	buf.encode_u32(1, peer_id)
	buf.encode_u32(5, item_id)
	buf.encode_u32(9, ammo)
	return buf


static func deserialize(data: PackedByteArray) -> TakeAmmoPacket:
	var _peer_id := data.decode_u32(1)
	var _item_id := data.decode_u32(5)
	var _ammo := data.decode_u32(9)
	return TakeAmmoPacket.new(_peer_id, _item_id, _ammo)
