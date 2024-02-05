extends Node

@onready var _room := $EuphRoom
@onready var _status := %Status
@onready var _messages := %Messages
@onready var _input := %Input

func _escape(text: String) -> String:
	return text.replace("[", "[lb]")

func _process(_delta):
	_status.text = _room.status()

func _on_euph_room_packet(packet: EuphPacket):
	if packet.type == "send-event":
		_messages.append_text("\n[b][lb]%s[rb][/b] %s" % [
			_escape(packet.data.sender.name),
			_escape(packet.data.content),
		])

func _send_msg():
	_room.send(EuphPacket.new("send", {"content": _input.text}))
	_input.clear()

func _on_send_button_pressed():
	_send_msg()

func _on_input_text_submitted(new_text):
	_send_msg()
