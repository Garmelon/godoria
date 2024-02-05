class_name EuphPacket

static var _last_id := 0

#region Fields

## Client-generated id for associating replies with commands.
## Optional.
var id

## The name of the command, reply, or event.
var type: String

## The payload of the command, reply, or event.
var data: Dictionary

## This field appears in replies if a command fails.
## Optional.
var error

## This field appears in replies to warn the client that it may be flooding.
## The client should slow down its command rate.
var throttled: bool

## If throttled is true, this field describes why.
## Optional.
var throttled_reason

#endregion

@warning_ignore("shadowed_variable")
func _init(type: String, data: Dictionary = {}):
	self.type = type
	self.data = data

## Generate a unique id if one is not already present.
func gen_id():
	if id != null: return
	id = str(_last_id)
	_last_id += 1

#region Parse

## Returns null if packet could not be parsed.
static func parse_dict(dict: Dictionary) -> EuphPacket:
	var packet = EuphPacket.new("placeholder")
	
	packet.id = dict.get("id")
	if not (packet.id == null or typeof(packet.id) == TYPE_STRING):
		push_error("packet.id must be null or a string")
		return null
	
	packet.type = dict["type"]
	if typeof(packet.type) != TYPE_STRING:
		push_error("packet.type must be a string")
		return null
	
	packet.data = dict.get("data", {})
	if typeof(packet.data) != TYPE_DICTIONARY:
		push_error("packet.data must be a json object")
		return null
	
	packet.error = dict.get("error")
	if not (packet.error == null or typeof(packet.error) == TYPE_STRING):
		push_error("packet.error must be null or a string")
		return null
	
	packet.throttled = dict.get("throttled", false)
	if typeof(packet.throttled) != TYPE_BOOL:
		push_error("packet.throttled must be a bool")
		return null
	
	packet.throttled_reason = dict.get("throttled_reason")
	if not (packet.throttled_reason == null or typeof(packet.throttled_reason) == TYPE_STRING):
		push_error("packet.throttled_reason must be null or a string")
		return null
	
	return packet

## Returns null if packet could not be parsed.
static func parse_json_string(json_string: String) -> EuphPacket:
	var packet: Variant = JSON.parse_string(json_string)
	
	if packet == null:
		push_error("packet must be valid json")
		return null
	
	if typeof(packet) != TYPE_DICTIONARY:
		push_error("packet must be a json object")
		return null
	
	return parse_dict(packet)

#endregion

#region Format

func dictify() -> Dictionary:
	var packet := {}
	
	if id != null:
		packet["id"] = id
	
	packet["type"] = type
	
	if data:
		packet["data"] = data
	
	if error != null:
		packet["error"] = error
	
	if throttled:
		packet["throttled"] = throttled
	
	if throttled_reason != null:
		packet["throttled_reason"] = throttled_reason
	
	return packet

func json_stringify() -> String:
	return JSON.stringify(dictify())

#endregion
