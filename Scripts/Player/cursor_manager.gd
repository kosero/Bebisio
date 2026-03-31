extends Node2D

const GUN_CROSSHAIR = preload("uid://cygaudjqhyh3s")

func _ready() -> void:
	update_cursor("gun")


func update_cursor(weapon_type: String):
	var cursor_texture
	var hotspot = Vector2(16, 16)

	match weapon_type:
		"gun":
			cursor_texture = GUN_CROSSHAIR
		_:
			cursor_texture = null

	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
