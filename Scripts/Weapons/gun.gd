extends Node2D

@export var radius: float = 12.0
@export var bullet: PackedScene
@export var amount: int = 0
@export var amount_max: int = 50

@onready var bullet_sound: AudioStreamPlayer2D = %BulletSound
@onready var anim: AnimatedSprite2D = %AnimatedSprite2D

@export var player: CharacterBody2D


func _input(event: InputEvent) -> void:
	if not player.is_local_player:
		return

	if event.is_action_pressed("shoot"):
		shoot()
		var p = ShootPacket.new(player.peer_id)
		NetworkHandler.send_packet(p)


func _process(_delta: float) -> void:
	if not player.is_local_player:
		return

	var mouse_pos: Vector2 = player.get_local_mouse_position()
	var angle = mouse_pos.angle()
	sync_position(angle)
	amount = clamp(amount, 0, amount_max)


func sync_position(angle: float) -> void:
	position = Vector2.from_angle(angle) * radius
	rotation = angle
	anim.flip_v = cos(angle) < 0


func shoot(shooter_id: int = -1) -> void:
	if amount > 0 or shooter_id != -1:
		_spawn_bullet()
		if !bullet_sound.playing:
			bullet_sound.play()
		player.camera.shake()
		player.recoil += -transform.x * 35.0


func take_ammo(ammo: int) -> void:
	amount += ammo


func _spawn_bullet(shooter_id: int = -1) -> void:
	var b = bullet.instantiate()
	b.global_position = global_position
	b.rotation = rotation
	b.shooter_id = shooter_id if shooter_id != -1 else player.peer_id
	get_tree().get_root().add_child(b)
