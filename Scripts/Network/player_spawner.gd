extends Node2D

@export var PLAYER: PackedScene


func _ready() -> void:
	PacketRouter.player_spawn.connect(_on_player_spawn)


func _on_player_spawn(_name: String, _peer_id: int) -> void:
	if NetworkHandler.get_player(_peer_id):
		return

	var player = PLAYER.instantiate()
	player.username = _name
	player.peer_id = _peer_id
	player.is_local_player = (_peer_id == NetworkHandler.client_id)

	NetworkHandler.register_player(_peer_id, player)
	player.tree_exited.connect(func(): NetworkHandler.unregister_player(_peer_id))

	call_deferred("add_child", player)
