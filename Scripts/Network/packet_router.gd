extends Node


signal player_spawn(name: String, peer_id: int)


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


func _welcome_packet_handle(data: PackedByteArray) -> void:
	var p = WelcomePacket.deserialize(data)
	NetworkHandler.client_id = p.client_id
	NetworkHandler.is_mine = true
	print_debug("ID assigned: ", p.client_id)


func _goodbye_packet_handle(data: PackedByteArray) -> void:
	var p = GoodbyePacket.deserialize(data)
	var player = _get_player_with_peer_id(p.client_id)
	if player:
		player.queue_free()


func _join_packet_handle(data: PackedByteArray) -> void:
	var p = JoinPacket.deserialize(data)
	player_spawn.emit(p.name, p.peer_id)


func _position_packet_handle(data: PackedByteArray) -> void:
	var p = PositionPacket.deserialize(data)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.global_position = Vector2(p.x, p.y)


func _take_cookie_packet_handle(data: PackedByteArray) -> void:
	var p = TakeCookiePacket.deserialize(data)
	var _player = _get_player_with_peer_id(p.peer_id)

	# TODO: Embed cookie counter inside player


func _take_ammo_packet_handle(data: PackedByteArray) -> void:
	var p = TakeAmmoPacket.deserialize(data)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.take_ammo(p.ammo)


func _shoot_packet_handle(data: PackedByteArray) -> void:
	var p = ShootPacket.deserialize(data)
	var player = _get_player_with_peer_id(p.peer_id)
	if player:
		player.gun.shoot()



func _get_player_with_peer_id(peer_id: int) -> Node:
	return get_tree().get_root().get_node_or_null(str(peer_id))
