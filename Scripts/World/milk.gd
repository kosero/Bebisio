extends Area2D

@export var item_id: int = 0
@export_range(1, 12) var amount: int = 6

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_local_player:
		set_deferred("monitoring", false)

		var p = TakeAmmoPacket.new(body.peer_id, item_id, amount)
		NetworkHandler.send_packet(p)
