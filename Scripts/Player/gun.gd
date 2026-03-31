extends Sprite2D

@export var radius: float = 12.0
@export var bullet: PackedScene
@export_range(1, 12) var amount: int = 0
@export_range(1, 12) var amount_max: int = 12

@onready var bullet_sound: AudioStreamPlayer2D = %BulletSound

func _input(event: InputEvent) -> void:
	if not get_parent().is_local_player:
		return

	if event.is_action_pressed("shoot"):
		shoot()
		var p = ShootPacket.new(get_parent().peer_id)
		NetworkHandler.send_packet(p)


func _process(_delta: float) -> void:
	if not get_parent().is_local_player:
		return

	var mouse_pos: Vector2 = get_parent().get_local_mouse_position()
	var angle = mouse_pos.angle()
	sync_position(angle)
	amount = clamp(amount, 0, amount_max)


func sync_position(angle: float) -> void:
	position = Vector2.from_angle(angle) * radius
	rotation = angle
	flip_v = cos(angle) < 0


func shoot(shooter_id: int = -1) -> void:
	if amount > 0 or shooter_id != -1:
		var b = bullet.instantiate()
		get_parent().add_child(b)
		b.global_position = global_position
		b.rotation = rotation
		b.shooter_id = shooter_id if shooter_id != -1 else get_parent().peer_id
		if !bullet_sound.playing:
			bullet_sound.play()
		if shooter_id == -1:
			amount -= 1


func take_ammo(ammo: int) -> void:
	amount += ammo
