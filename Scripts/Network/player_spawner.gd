extends Node2D

@export var PLAYER: PackedScene


func _ready() -> void:
	PacketRouter.player_spawn.connect(_on_player_spawn)


func _on_player_spawn(_name: String, peer_id: int) -> void:
	var player = PLAYER.instantiate()
	player.username = _name
	player.name = str(peer_id)
	call_deferred("add_child", player)
