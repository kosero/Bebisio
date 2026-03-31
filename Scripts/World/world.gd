extends Node2D


func _ready() -> void:
	randomize()
	if NetworkHandler.client_id != -1:
		_join_game()
	else:
		NetworkHandler.packet_received.connect(_on_packet_received)


func _on_packet_received(data: PackedByteArray) -> void:
	if Packet.get_type(data) == Packet.WELCOME:
		_join_game()
		NetworkHandler.packet_received.disconnect(_on_packet_received)


func _join_game() -> void:
	await get_tree().process_frame
	var player_name = NetworkHandler.player_name
	if player_name.is_empty():
		player_name = _generate_random_name()
		
	var join := JoinPacket.new(player_name, NetworkHandler.client_id)
	NetworkHandler.send_packet(join)


func _generate_random_name() -> String:
	var adjectives = [
		"Crazy", "Mega", "Tiny", "Super", "Mighty", "Cool", "Fast", "Smart", "Brave", "Shiny",
		"Happy", "Angry", "Sleepy", "Bouncy", "Zesty", "Epic", "Silly", "Wise", "Bold", "Wild",
		"Turbo", "Neo", "Dark", "Light", "Fire", "Ice", "Space", "Drift", "Metal", "Glass"
	]
	var adj = adjectives[randi() % adjectives.size()]
	var num = randi() % 1000
	return "%sBebis_%03d" % [adj, num]
