extends Node

signal packet_received(data: PackedByteArray)

var ws: WebSocketPeer
var client_id: int = -1
var player_name: String = ""
var players: Dictionary = {}

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
			_clear_players()
			_try_reconnect(delta)


func _clear_players() -> void:
	for id in players.keys():
		var p = players[id]
		if is_instance_valid(p):
			p.queue_free()
	players.clear()


func _handle_incoming_packets() -> void:
	while ws.get_available_packet_count():
		var packet = ws.get_packet()
		packet_received.emit(packet)


func send_packet(p: Packet) -> void:
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.put_packet(p.serialize())


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


func register_player(peer_id: int, player_node: Node) -> void:
	players[peer_id] = player_node


func unregister_player(peer_id: int) -> void:
	players.erase(peer_id)


func get_player(peer_id: int) -> Node:
	return players.get(peer_id)
