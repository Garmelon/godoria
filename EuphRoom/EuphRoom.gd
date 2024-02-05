extends Node

signal joined()
signal packet(packet: EuphPacket)

@export var domain := "euphoria.leet.nu"
@export var room := "test"
@export var nick := "godot"
@export var autoconnect := false

@onready var _reconnect_timer := $ReconnectTimer

var _socket: WebSocketPeer
var _joined: bool

func status() -> String:
	if not _socket:
		if _reconnect_timer.is_stopped(): return "stopped"
		return "waiting"
	match _socket.get_ready_state():
		WebSocketPeer.STATE_CONNECTING: return "connecting"
		WebSocketPeer.STATE_OPEN when _joined: return "joined"
		WebSocketPeer.STATE_OPEN : return "joining"
		WebSocketPeer.STATE_CLOSING: return "closing"
		WebSocketPeer.STATE_CLOSED: return "closed"
	return "unknown"

func reconnect():
	# Assumes gc will close the previous socket, if any
	var url := "wss://%s/room/%s/ws" % [domain, room]
	_socket = WebSocketPeer.new()
	_socket.connect_to_url(url)
	_joined = false

func send(p: EuphPacket):
	print("=> ", p.json_stringify())
	if not _socket:
		push_warning("Tried to send ", p.type, " while not connected")
		return
	
	_socket.send_text(p.json_stringify())

func _on_packet(p: EuphPacket):
	print("<= ", p.json_stringify())
	if p.type == "ping-event":
		send(EuphPacket.new("ping-reply", {"time": p.data.time}))
	
	if p.type == "snapshot-event":
		send(EuphPacket.new("nick", {"name": nick}))
		_joined = true
		joined.emit()
	
	packet.emit(p)

func _on_raw_packet(raw_packet: PackedByteArray, is_text: bool):
	if not is_text:
		push_error("packet must be text")
		return
	
	var text := raw_packet.get_string_from_utf8()
	var p := EuphPacket.parse_json_string(text)
	if p:
		_on_packet(p)

func _ready():
	if autoconnect:
		reconnect()

func _process(_delta):
	if not _socket: return
	
	_socket.poll()
	
	var state := _socket.get_ready_state()
	
	# Reconnect if necessary
	if state == WebSocketPeer.STATE_CLOSED:
		_reconnect_timer.start()
		_socket = null
		return
	
	if state != WebSocketPeer.STATE_OPEN:
		return
	
	while _socket.get_available_packet_count() > 0:
		var raw_packet := _socket.get_packet()
		var is_text := _socket.was_string_packet()
		_on_raw_packet(raw_packet, is_text)

func _on_reconnect_timer_timeout():
	reconnect()
