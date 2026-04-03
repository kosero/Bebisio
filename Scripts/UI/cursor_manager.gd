extends Node2D

const GUN_CROSSHAIR = preload("uid://cygaudjqhyh3s")
const NONE_CURSOR = preload("uid://ob6quw1j1pho")

func _ready() -> void:
	update_cursor("")

func update_cursor(weapon_type: String):
	var cursor_texture
	var hotspot: Vector2 = Vector2(0, 0)

	match weapon_type:
		"gun":
			cursor_texture = GUN_CROSSHAIR
			hotspot = Vector2(16, 16)
		_:
			cursor_texture = NONE_CURSOR
			hotspot = Vector2(0, 0)

	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
