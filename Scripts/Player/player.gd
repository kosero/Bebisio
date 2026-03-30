extends CharacterBody2D

enum State { idle, walk }

@export var state: State = State.idle
var current_face: String = "down"

@export_group("Network")
var peer_id: int = -1
var is_local_player: bool = false
var target_position: Vector2 = Vector2.ZERO
var interpolation_speed: float = 15.0

@export_group("Movement")
@export var ACCELERATION: float = 800.0
@export var FRICTION: float = 1000.0
@export var SPEED: float = 80.0

@export var username: String = ""

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var shape: ShapeCast2D = %ShapeCast2D
@onready var gun: Sprite2D = %Gun
@onready var username_label: Label = %Username

var previous_colliders: Array = []
var last_sent_position: Vector2 = Vector2.ZERO
var position_send_timer: float = 0.0
const POSITION_SEND_INTERVAL: float = 0.05 # 20 Hz

var cookie_counter: int = 0
@onready var ham_sound: AudioStreamPlayer2D = %HamSound

func _ready() -> void:
	target_position = global_position
	username_label.text = username


func _physics_process(delta: float) -> void:
	if is_local_player:
		_raycast_handle()
		_movement_handle(delta)
		_state_manager()
		_animation_manager()
		move_and_slide()
		_send_position_to_server(delta)
	else:
		_interpolate_remote_player(delta)


func _interpolate_remote_player(delta: float) -> void:
	global_position = global_position.lerp(target_position, interpolation_speed * delta)

	var movement_delta = target_position - global_position
	if movement_delta.length() > 0.1:
		state = State.walk
		velocity = movement_delta # Used by _update_face
	else:
		state = State.idle

	_update_face()
	_animation_manager()


func _send_position_to_server(delta: float) -> void:
	position_send_timer += delta
	if position_send_timer >= POSITION_SEND_INTERVAL:
		if global_position.distance_to(last_sent_position) > 0.1:
			var p = PositionPacket.new(global_position.x, global_position.y, peer_id)
			NetworkHandler.send_packet(p)
			last_sent_position = global_position
		position_send_timer = 0.0


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


func _raycast_handle() -> void:
	var current_colliders: Array = []

	if shape.is_colliding():
		for i in shape.get_collision_count():
			var body = shape.get_collider(i)
			if body == null or body.is_in_group("wall") or body == self:
				continue

			current_colliders.append(body)

			var space = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(
				global_position,
				body.global_position
			)
			query.exclude = [self]
			query.collision_mask = 1

			var result = space.intersect_ray(query)

			if not result or result.collider == body:
				body.visible = true
			else:
				body.visible = false

	for body in previous_colliders:
		if not current_colliders.has(body) and is_instance_valid(body):
			body.visible = false
	previous_colliders = current_colliders


func take_cookie(amount: int = 1) -> void:
	cookie_counter += amount
	ham_sound.play()


func take_damage() -> void:
	pass
