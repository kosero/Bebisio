extends CharacterBody2D

enum State { idle, walk }

@export var state: State = State.idle
var current_face: String = "down"

@export_group("Movement")
@export var ACCELERATION: float = 800.0
@export var FRICTION: float = 1000.0
@export var SPEED: float = 80.0

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D

func _physics_process(delta: float) -> void:
	_movement_handle(delta)
	_state_manager()
	_animation_manager()
	move_and_slide()


func _movement_handle(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)


func _update_face() -> void:
	if velocity.length() < 0.1:
		return
	if abs(velocity.x) > abs(velocity.y):
		current_face = "right" if velocity.x > 0 else "left"
	else:
		current_face = "down" if velocity.y > 0 else "up"


func _state_manager() -> void:
	_update_face()
	if velocity.length() > 5.0: 
		state = State.walk
	else:
		state = State.idle


func _animation_manager() -> void:
	var base_name = "walk" if state == State.walk else "idle"
	var full_anim_name = base_name + "_" + current_face
	
	if anim.animation != full_anim_name:
		anim.play(full_anim_name)
