extends Node


func _ready() -> void:
	NetworkHandler.packet_received.connect(_on_packet_received)


func _on_packet_received(data: PackedByteArray) -> void:
	var type = Packet.get_type(data)
	match type:
		Packet.WELCOME:
			var p = WelcomePacket.deserialize(data)
			NetworkHandler.client_id = p.client_id
			NetworkHandler.is_mine = true
			print_debug("ID assigned: ", p.client_id)

		Packet.GOODBYE:
			var p = GoodbyePacket.deserialize(data)
			var player = get_tree().get_root().get_node_or_null(str(p.client_id))
			if player:
				player.queue_free()

		Packet.POSITION:
			var p = PositionPacket.deserialize(data)
			var player = get_tree().get_root().get_node_or_null(str(p.peer_id))
			if player:
				player.global_position = Vector2(p.x, p.y)
