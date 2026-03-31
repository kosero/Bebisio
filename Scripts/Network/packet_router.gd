extends Node


signal player_spawn(name: String, peer_id: int)
signal spawn_item(item_type: int, item_id: int, spawner_id: int)


func _ready() -> void:
	NetworkHandler.packet_received.connect(_on_packet_received)


func _on_packet_received(data: PackedByteArray) -> void:
	var type = Packet.get_type(data)
	match type:
		Packet.WELCOME:
			_welcome_packet_handle(data)

		Packet.GOODBYE:
			_goodbye_packet_handle(data)

		Packet.JOIN:
			_join_packet_handle(data)

		Packet.POSITION:
			_position_packet_handle(data)

		Packet.SHOOT:
			_shoot_packet_handle(data)

		Packet.TAKE_COOKIE:
			_take_cookie_packet_handle(data)

		Packet.TAKE_AMMO:
			_take_ammo_packet_handle(data)

		Packet.SPAWN_ITEM:
			_spawn_item_packet_handle(data)


func _welcome_packet_handle(data: PackedByteArray) -> void:
	var p = WelcomePacket.deserialize(data)
	NetworkHandler.client_id = p.client_id
	print_debug("ID assigned: ", p.client_id)


func _goodbye_packet_handle(data: PackedByteArray) -> void:
	var p = GoodbyePacket.deserialize(data)
	var player = _get_player_with_peer_id(p.client_id)
	if player:
		player.queue_free()


func _join_packet_handle(data: PackedByteArray) -> void:
	var p = JoinPacket.deserialize(data)
	player_spawn.emit(p.name, p.peer_id)


func _spawn_item_packet_handle(data: PackedByteArray) -> void:
	var p = SpawnItemPacket.deserialize(data)
	spawn_item.emit(p.item_type, p.item_id, p.spawner_id)


func _position_packet_handle(data: PackedByteArray) -> void:
	var p = PositionPacket.deserialize(data)

	if p.peer_id == NetworkHandler.client_id:
		return

	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.target_position = Vector2(p.x, p.y)


func _take_cookie_packet_handle(data: PackedByteArray) -> void:
	var p = TakeCookiePacket.deserialize(data)
	
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.take_cookie()
		
	var cookie = _get_cookie_with_id(p.cookie_id)
	if cookie:
		cookie.queue_free()


func _get_cookie_with_id(id: int) -> Node:
	for cookie in get_tree().get_nodes_in_group("cookie"):
		if "cookie_id" in cookie and cookie.cookie_id == id:
			return cookie
	return null


func _take_ammo_packet_handle(data: PackedByteArray) -> void:
	var p = TakeAmmoPacket.deserialize(data)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.gun.take_ammo(p.ammo)
		
	var milk = _get_milk_with_id(p.item_id)
	if milk:
		milk.queue_free()


func _get_milk_with_id(id: int) -> Node:
	for milk in get_tree().get_nodes_in_group("milk"):
		if "item_id" in milk and milk.item_id == id:
			return milk
	return null


func _shoot_packet_handle(data: PackedByteArray) -> void:
	var p = ShootPacket.deserialize(data)

	if p.peer_id == NetworkHandler.client_id:
		return

	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.gun.shoot()


func _get_player_with_peer_id(peer_id: int) -> Node:
	return NetworkHandler.get_player(peer_id)
