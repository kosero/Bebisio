extends Control

@export var health_progress: ProgressBar

@onready var health_bar: TextureRect = %HealthBar
var health_mat: ShaderMaterial

@onready var bullet_bar: TextureRect = %BulletBar
var bullet_mat: ShaderMaterial

@onready var message_box: RichTextLabel = %Messagebox
@onready var anim: AnimationPlayer = %AnimationPlayer
@export var player: CharacterBody2D


func _ready() -> void:
	if bullet_bar.material:
		bullet_bar.material = bullet_bar.material.duplicate()
	if health_bar.material:
		health_bar.material = health_bar.material.duplicate()

	bullet_mat = bullet_bar.material as ShaderMaterial
	health_mat = health_bar.material as ShaderMaterial
	health_progress.visible = not player.is_local_player

	PacketRouter.player_spawn.connect(_on_player_spawn)
	PacketRouter.player_goodbye.connect(_on_player_goodbye)
	PacketRouter.player_dead.connect(_on_player_dead)
	PacketRouter.player_respawn.connect(_on_player_respawn)


func _process(_delta: float) -> void:
	if player.is_local_player:
		if bullet_mat:
			var ratio = float(player.gun.amount) / float(player.gun.amount_max)
			bullet_mat.set_shader_parameter("center", ratio)
		if health_mat:
			var ratio = float(player.health) / float(10)
			health_mat.set_shader_parameter("center", ratio)

	health_progress.value = player.health


func _on_player_spawn(_name: String, _peer_id: int) -> void:
	message_box.text += _name + " joined\n"
	anim.play("transition")


func _on_player_goodbye(_client_id: int, _name: String) -> void:
	message_box.text += _name + " left\n"
	anim.play("transition")


func _on_player_dead(_name: String, _peer_id: int) -> void:
	message_box.text += _name + " dead\n"
	anim.play("transition")


func _on_player_respawn(_name: String, _peer_id: int) -> void:
	message_box.text += _name + " respawn\n"
	anim.play("transition")
