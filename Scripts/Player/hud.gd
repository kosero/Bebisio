extends Control

@onready var health_progress: ProgressBar = %health_progress
@onready var health_bar: TextureRect = %HealthBar
var health_mat: ShaderMaterial

@onready var bullet_bar: TextureRect = %BulletBar
var bullet_mat: ShaderMaterial

@onready var message_box: RichTextLabel = %Messagebox
@onready var player: Node = get_parent().get_parent()

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
	player.anim_play.play("transition")


func _on_player_goodbye(_client_id: int, _name: String) -> void:
	message_box.text += _name + " left\n"
	player.anim_play.play("transition")
