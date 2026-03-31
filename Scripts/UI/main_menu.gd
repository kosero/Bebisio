extends Control

@onready var name_entry: LineEdit = %NameEntry


func _on_name_entry_text_submitted(new_text: String) -> void:
	NetworkHandler.player_name = new_text
	ScenesLoader.load_scene("res://Scenes/world.tscn")
