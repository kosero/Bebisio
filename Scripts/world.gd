extends Node2D


func _ready() -> void:
	NetworkHandler.packet_received.connect(
		func(data: PackedByteArray):
			if Packet.get_type(data) == Packet.WELCOME:
				await get_tree().process_frame
				var join := JoinPacket.new("vay be!", NetworkHandler.client_id)
				NetworkHandler.send_packet(join)
	)
