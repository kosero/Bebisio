extends Node

signal packet_received(data: PackedByteArray)

var ws: WebSocketPeer

const WEBSOCKET_URL: String = "ws://localhost:8965"
const RECONNECT_INTERVAL: float = 2.0

var _reconnect_timer: float = 0.0

func _ready() -> void:
	_websocket_connect()


func _process(delta: float) -> void:
	ws.poll()

	var state = ws.get_ready_state()
	match state:
		WebSocketPeer.STATE_OPEN:
			_handle_incoming_packets()
		WebSocketPeer.STATE_CLOSING:
			print("Closing...")
		WebSocketPeer.STATE_CLOSED:
			_try_reconnect(delta)


func _handle_incoming_packets() -> void:
	while ws.get_available_packet_count():
		var packet = ws.get_packet()
		packet_received.emit(packet)


func _try_reconnect(delta) -> void:
	_reconnect_timer += delta
	if _reconnect_timer >= RECONNECT_INTERVAL:
		_reconnect_timer = 0.0
		_websocket_connect()


func _websocket_connect() -> void:
	ws = WebSocketPeer.new()
	var err = ws.connect_to_url(WEBSOCKET_URL)
	if err == OK:
		print_debug("Connecting to %s..." % WEBSOCKET_URL)
	else:
		push_error("Unable to initiate connection")
