extends Control


# @onready var health_bar: ProgressBar = %HealthBar
@onready var bullet_bar: ProgressBar = %BulletBar
@onready var cookie_counter: Label = %CookieCounter


func _process(_delta: float) -> void:
	cookie_counter.text = str(get_parent().cookie_counter)
	bullet_bar.value = get_parent().gun.amount
