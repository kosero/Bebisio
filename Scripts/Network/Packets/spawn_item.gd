class_name SpawnItemPacket extends Packet

var item_type: int
var item_id: int
var spawner_id: int

func _init(_item_type: int, _item_id: int, _spawner_id: int) -> void:
	type = Packet.SPAWN_ITEM
	item_type = _item_type
	item_id = _item_id
	spawner_id = _spawner_id

func serialize() -> PackedByteArray:
	var buf := PackedByteArray()
	buf.resize(1 + 1 + 4 + 4)
	buf[0] = type
	buf.encode_u8(1, item_type)
	buf.encode_u32(2, item_id)
	buf.encode_u32(6, spawner_id)
	return buf

static func deserialize(data: PackedByteArray) -> SpawnItemPacket:
	var _item_type := data.decode_u8(1)
	var _item_id := data.decode_u32(2)
	var _spawner_id := data.decode_u32(6)
	return SpawnItemPacket.new(_item_type, _item_id, _spawner_id)
