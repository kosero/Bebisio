extends Area2D


@export var speed: float = 500.0
var velocity: Vector2
var shooter_id: int = -1


func _ready() -> void:
	collision_mask = 3
	get_tree().create_timer(4.0).timeout.connect(queue_free)


func _process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.peer_id == shooter_id:
			return
		if body.is_local_player:
			body.take_damage()
		queue_free()
	elif body.is_in_group("wall"):
		queue_free()
