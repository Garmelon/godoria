extends Node

func _process(_delta):
	$Label.text = $EuphRoom.status()

func _on_euph_room_packet(packet: EuphPacket):
	print("| ", packet.json_stringify())
