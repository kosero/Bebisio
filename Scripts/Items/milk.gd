extends Area2D

@export var item_id: int = 0

func _ready() -> void:
	add_to_group("milk")
	collision_mask = 2


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_local_player:
		set_deferred("monitoring", false)
		var p = TakeAmmoPacket.new(body.peer_id, item_id, 0)
		NetworkHandler.send_packet(p)
