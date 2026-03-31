extends Control


@onready var health_bar: ProgressBar = %HealthBar
@onready var bullet_bar: ProgressBar = %BulletBar
@onready var cookie_counter_label: Label = %CookieCounterLabel


@onready var player: Node = get_parent().get_parent()


func _process(_delta: float) -> void:
	cookie_counter_label.text = str(player.cookie_counter)
	bullet_bar.value = player.gun.amount
	health_bar.value = player.health
