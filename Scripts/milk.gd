extends Area2D

@export_range(1, 12) var amout: int = 6

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_ammo(amout)
		queue_free()
