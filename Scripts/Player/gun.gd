@tool
extends Sprite2D

@export var radius: float = 12.0

func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
	var angle = mouse_pos.angle()
	position = Vector2.from_angle(angle) * radius
	rotation = angle
	flip_v = mouse_pos.x < 0
