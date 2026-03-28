@tool
extends Sprite2D

@export var radius: float = 12.0
@export var bullet: PackedScene

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot()


func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
	var angle = mouse_pos.angle()
	position = Vector2.from_angle(angle) * radius
	rotation = angle
	flip_v = mouse_pos.x < 0


func _shoot() -> void:
	var b = bullet.instantiate()
	get_parent().add_child(b)
	b.global_position = global_position
	b.rotation = rotation
