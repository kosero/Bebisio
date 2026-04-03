extends CharacterBody2D

enum State { idle, walk }

@export var state: State = State.idle
var current_face: String = "down"

@export_group("Network")
var peer_id: int = -1
var is_local_player: bool = false
var target_position: Vector2 = Vector2.ZERO
var interpolation_speed: float = 15.0

var last_sent_position: Vector2 = Vector2.ZERO
var position_send_timer: float = 0.0
const POSITION_SEND_INTERVAL: float = 0.05

@export_group("Movement")
@export var ACCELERATION: float = 2000.0
@export var FRICTION: float = 2000.0
@export var SPEED: float = 80.0

var recoil: Vector2 = Vector2.ZERO

@export var dash_curve: Curve
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 2.0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_cooldown_timer: float = 0.0

@export_group("Items")
var cookie_counter: int = 0
var health: int = 10

var username: String = ""

@onready var ham_sound: AudioStreamPlayer2D = %HamSound
@onready var ugh_sound: AudioStreamPlayer2D = %UghSound
@onready var dash_sound: AudioStreamPlayer2D = %DashSound

@onready var anim: AnimatedSprite2D = %AnimatedSprite2D
@onready var gun: Node2D = %Gun
@onready var username_label: Label = %Username
@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var audio_listener: AudioListener2D = %AudioListener2D
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var camera: Camera2D = %Camera


func _ready() -> void:
	target_position = global_position
	username_label.text = username
	CursorManager.update_cursor("gun")

	collision_layer = 2
	collision_mask = 1

	canvas_layer.visible = is_local_player
	canvas_modulate.visible = is_local_player
	if is_local_player:
		audio_listener.make_current()
	if anim.material:
		anim.material = anim.material.duplicate()


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
	if is_dashing:
		if not dash_sound.playing:
			dash_sound.play()

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

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0.0:
		is_dashing = true
		dash_timer = 0.0
		dash_direction = direction
		dash_cooldown_timer = dash_cooldown
		if dash_direction == Vector2.ZERO:
			match  current_face:
				"right": dash_direction = Vector2.RIGHT
				"left": dash_direction = Vector2.LEFT
				"down": dash_direction = Vector2.DOWN
				"up": dash_direction = Vector2.UP

	if is_dashing:
		var progress := dash_timer / dash_duration
		var  curve_value := dash_curve.sample(progress)
		velocity = dash_direction * dash_speed * curve_value
		dash_timer += delta
		if not dash_sound.playing:
			dash_sound.play()
		if dash_timer >= dash_duration:
			is_dashing = false
		return

	if direction:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	velocity += recoil
	recoil = recoil.move_toward(Vector2.ZERO, 500 * delta)


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

	if not is_dashing:
		if anim.animation != full_anim_name:
			anim.play(full_anim_name)
	else:
		anim.play("dash")


func take_cookie(_amount: int = 2) -> void:
	health += _amount
	health = clamp(health, 0, 10)
	ham_sound.play()


func take_damage(amount = 1) -> void:
	health -= amount
	ugh_sound.play()
	health = clamp(health, 0, 10)
	if anim.material:
		anim.material.set_shader_parameter("hit_effect", 0.2)
		var tween = create_tween()
		tween.tween_property(anim.material, "shader_parameter/hit_effect", 0.0, 0.5)
	if health <= 0 and is_local_player:
		player_dead()


func player_dead() -> void:
	if not is_local_player:
		return
	var p = DeathPacket.new(peer_id, username)
	NetworkHandler.send_packet(p)
	send_respawn_packet()


func respawn() -> void:
	health = 10
	cookie_counter = 0
	gun.amount = 0
	position = Vector2.ZERO
	target_position = global_position
	last_sent_position = global_position


func send_respawn_packet() -> void:
	var p = RespawnPacket.new(peer_id, username)
	NetworkHandler.send_packet(p)
