extends Node


signal player_spawn(name: String, peer_id: int)
signal player_goodbye(client_id: int, name: String)
signal player_respawn(name: String, peer_id: int)
signal player_dead(name: String, peer_id: int)

signal spawn_item(item_type: int, item_id: int, progress: float)


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

		Packet.RESPAWN:
			_respawn_packet_handle(data)

		Packet.DEATH:
			_death_packet_handle(data)


func _welcome_packet_handle(data: PackedByteArray) -> void:
	var p = WelcomePacket.deserialize(data)
	NetworkHandler.client_id = p.client_id
	print_debug("ID assigned: ", p.client_id)


func _goodbye_packet_handle(data: PackedByteArray) -> void:
	var p = GoodbyePacket.deserialize(data)
	var player = _get_player_with_peer_id(p.client_id)
	if player:
		player.queue_free()
		player_goodbye.emit(p.client_id, p.name)


func _join_packet_handle(data: PackedByteArray) -> void:
	var p = JoinPacket.deserialize(data)
	player_spawn.emit(p.name, p.peer_id)


func _spawn_item_packet_handle(data: PackedByteArray) -> void:
	var p = SpawnItemPacket.deserialize(data)
	spawn_item.emit(p.item_type, p.item_id, p.progress)


func _position_packet_handle(data: PackedByteArray) -> void:
	var p = PositionPacket.deserialize(data)

	if p.peer_id == NetworkHandler.client_id:
		return

	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.target_position = Vector2(p.x, p.y)
		player.health = p.health
		if player.gun:
			player.gun.rotation = p.look_angle
			player.gun.sync_position(p.look_angle)


func _take_cookie_packet_handle(data: PackedByteArray) -> void:
	var p = TakeCookiePacket.deserialize(data)

	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.take_cookie(p.amount)

	var cookie = _get_cookie_with_id(p.cookie_id)
	if cookie:
		cookie.queue_free()


func _get_cookie_with_id(id: int) -> Node:
	for cookie in get_tree().get_nodes_in_group("cookie"):
		if "item_id" in cookie and cookie.item_id == id:
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

	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		# Her iki durumda da (yerel veya uzak) mermiyi düşürüyoruz
		# Çünkü sunucu bu vuruşu onayladı (paket bize geri geldi)
		if player.gun.amount > 0:
			player.gun.amount -= 1

		# if p.peer_id == NetworkHandler.client_id:
		# 	return # Yerel oyuncu zaten vuruş sesini/animasyonunu shoot() içinde yaptı mı?
		# Hayır, gun.gd içindeki shoot() mermiyi düşürmüyordu artık.

		if p.peer_id != NetworkHandler.client_id:
			player.gun.shoot(p.peer_id)


func _respawn_packet_handle(data: PackedByteArray) -> void:
	var p = RespawnPacket.deserialize(data)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.respawn()
	player_respawn.emit(p.name, p.peer_id)

func _death_packet_handle(data: PackedByteArray) -> void:
	var p = DeathPacket.deserialize(data)
	player_dead.emit(p.name, p.peer_id)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		# Maybe trigger visual death locally too, if you want.
		pass


func _get_player_with_peer_id(peer_id: int) -> Node:
	return NetworkHandler.get_player(peer_id)
