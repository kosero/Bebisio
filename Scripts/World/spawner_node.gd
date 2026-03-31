extends Node2D

@export var spawner_id: int = 0
@export var milk_scene: PackedScene
@export var cookie_scene: PackedScene


func _ready() -> void:
	PacketRouter.spawn_item.connect(_on_spawn_item)


func _on_spawn_item(item_type: int, item_id: int, _spawner_id: int) -> void:
	if spawner_id != _spawner_id:
		return

	var instance: Node2D = null

	if item_type == 0 and milk_scene:
		instance = milk_scene.instantiate()
		instance.item_id = item_id

	elif item_type == 1 and cookie_scene:
		instance = cookie_scene.instantiate()
		instance.item_id = item_id

	if instance:
		instance.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", instance)
