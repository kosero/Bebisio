extends Node


func _ready() -> void:
	NetworkHandler.packet_received.connect(_on_packet_received)


func _on_packet_received(data: PackedByteArray) -> void:
	match Packet.get_type(data):
		Packet.POSITION:
			print_debug("position")
