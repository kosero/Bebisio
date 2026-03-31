extends Node2D

@export var milk_scene: PackedScene
@export var cookie_scene: PackedScene
@export var spawn_path: Path2D

func _ready() -> void:
	PacketRouter.spawn_item.connect(_on_spawn_item)


func _on_spawn_item(item_type: int, item_id: int, progress: float) -> void:
	var instance: Node2D = null

	if item_type == 0 and milk_scene:
		instance = milk_scene.instantiate()
		instance.item_id = item_id

	elif item_type == 1 and cookie_scene:
		instance = cookie_scene.instantiate()
		instance.item_id = item_id

	if instance:
		if spawn_path and spawn_path.curve:
			var curve = spawn_path.curve
			instance.global_position = spawn_path.global_position + curve.sample_baked(progress * curve.get_baked_length())
		else:
			instance.global_position = global_position
			
		get_tree().current_scene.call_deferred("add_child", instance)
