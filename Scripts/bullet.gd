extends Area2D


@export var speed: float = 250.0
var velocity: Vector2


func _ready() -> void:
	get_tree().create_timer(4.0).timeout.connect(queue_free)


func _process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_local_player:
		body.take_damage()
