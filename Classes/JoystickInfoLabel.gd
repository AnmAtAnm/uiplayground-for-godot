extends Label


class Joystick:
	var id :int
	var description :String
	
	func _init(id):
		self.id = id
		build_description(id)
		
	func build_description(device_id):
		description = "Joystick #" + str(device_id) + ": " + Input.get_joy_guid(device_id)


# Array of arrays: The inner array is [device id, guid, device text]
var _joysticks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var joy_detector = get_node("/root/JoyDetector")
	ConnectTo.orDie(joy_detector,"joy_connection_changed", self, "_on_joystick_detected")
	_rebuild_text()


func _on_joystick_detected(device_id: int, device_connected :bool):
	var index = _find_by_id(device_id)
	if index == -1:
		# New device
		if device_connected:
			_joysticks.append(Joystick.new(device_id))
	else:
		# Old device
		var joystick = _joysticks[index]
		if device_connected:
			# Device was updated
			joystick.guid = Input.get_joy_guid(device_id)
			joystick.build_description()
		else:
			_joysticks.remove(index)
	_rebuild_text()

func _find_by_id(device_id :int) -> int:
	for i in _joysticks.size():
		var joystick = _joysticks[i]
		if joystick.id == device_id:
			return i
	return -1  # Not Found

func _rebuild_text():
	if _joysticks.empty():
		text = "No joystick devices."
	else:
		text = ""
		for joy in _joysticks:
			text += ("" if text.empty() else "\n") + joy.description
