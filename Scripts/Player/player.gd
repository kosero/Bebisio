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
@onready var camera: Camera2D = $Camera2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var audio_listener: AudioListener2D = $AudioListener2D
@onready var canvas_modulate: CanvasModulate = $CanvasModulate


var previous_colliders: Array = []
var last_sent_position: Vector2 = Vector2.ZERO
var position_send_timer: float = 0.0
const POSITION_SEND_INTERVAL: float = 0.05 # 20 Hz

var cookie_counter: int = 0
@onready var ham_sound: AudioStreamPlayer2D = %HamSound

var health: int = 10


func _ready() -> void:
	target_position = global_position
	username_label.text = username

	collision_layer = 2
	collision_mask = 1

	camera.enabled = is_local_player
	canvas_layer.visible = is_local_player
	canvas_modulate.visible = is_local_player
	if is_local_player:
		audio_listener.make_current()


func _physics_process(delta: float) -> void:
	if is_local_player:
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
		velocity = movement_delta
	else:
		state = State.idle

	_update_face()
	_animation_manager()


func _send_position_to_server(delta: float) -> void:
	if peer_id == -1:
		return

	position_send_timer += delta
	if position_send_timer >= POSITION_SEND_INTERVAL:
		if global_position.distance_to(last_sent_position) > 0.1 or true:
			var p = PositionPacket.new(global_position.x, global_position.y, gun.rotation, health, peer_id)
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


func take_cookie(amount: int = 1) -> void:
	cookie_counter += amount
	ham_sound.play()


func take_damage(amount = 1) -> void:
	health -= amount
	health = clamp(health, 0, 10)
	if health <= 0:
		player_dead()


func player_dead() -> void:
	if not is_local_player:
		return
	var p = RespawnPacket.new(peer_id)
	NetworkHandler.send_packet(p)


func respawn() -> void:
	health = 10
	cookie_counter = 0
	gun.amount = 0
	position = Vector2.ZERO
	target_position = global_position
	last_sent_position = global_position
