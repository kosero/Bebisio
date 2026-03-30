extends Area2D

@export var cookie_id: int = 0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_local_player:
		set_deferred("monitoring", false)
		
		var p = TakeCookiePacket.new(body.peer_id, cookie_id)
		NetworkHandler.send_packet(p)
