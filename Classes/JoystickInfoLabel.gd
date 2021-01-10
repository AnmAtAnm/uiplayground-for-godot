extends Label

const _MAX_DEVICE_ID = 100


# Array of arrays: The inner array is [device id, guid, device text]
var _data = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialSearchForDevices()
	_rebuild_text()
	ConnectTo.orDie(Input,"joy_connection_changed", self, "_updateJoystickInfo")

func _initialSearchForDevices():
	for device_id in _MAX_DEVICE_ID:
		if Input.is_joy_known(device_id) and not Input.get_joy_guid(device_id).empty():
			_data.append(_build_device_record(device_id))

func _build_device_text(device_id) -> String:
	return "Joystick #" + str(device_id) + ": " + Input.get_joy_guid(device_id)

func _build_device_record(device_id: int) -> Array:
	return [device_id, Input.get_joy_guid(device_id), _build_device_text(device_id)]

# Find the index for the device_id in _data
func _find_index(device_id) -> int:
	var guid = Input.get_joy_guid(device_id)
	for i in _data.size():
		var record = _data[i]
		if record[0] == device_id and record[1] == guid:
			return i
	return -1  # Not Found

func _find_insertion_point(device_id :int) -> int:
	return _data.size()

func _updateJoystickInfo(device_id :int, connected :bool):
	if device_id >= 0:
		var index = _find_index(device_id)
		if connected and index > -1:
			_data.insert(index, _build_device_record(device_id))
		else:
			if index != -1:
				_data.remove(-1)
	_rebuild_text()

func _rebuild_text():
	if _data.empty():
		text = "No joystick devices."
	else:
		text = ""
		for record in _data:
			text += ("" if text.empty() else "\n") + record[1]
