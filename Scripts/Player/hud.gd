extends Control

@onready var health_progress: ProgressBar = %health_progress
@onready var health_bar: Sprite2D = %HealthBar
var health_mat: ShaderMaterial

@onready var bullet_bar: Sprite2D = %BulletBar
var bullet_mat: ShaderMaterial

@onready var cookie_counter_label: Label = %CookieCounterLabel
@onready var player: Node = get_parent().get_parent()

func _ready() -> void:
	bullet_mat = bullet_bar.material as ShaderMaterial
	health_mat = health_bar.material as ShaderMaterial
	health_progress.visible = not player.is_local_player


func _process(_delta: float) -> void:
	cookie_counter_label.text = str(player.cookie_counter)
	if bullet_mat:
		var ratio = float(player.gun.amount) / float(player.gun.amount_max)
		bullet_mat.set_shader_parameter("center", ratio)
	
	if health_mat:
		var ratio = float(player.health) / float(10)
		health_mat.set_shader_parameter("center", ratio)
	
	health_progress.value = player.health
