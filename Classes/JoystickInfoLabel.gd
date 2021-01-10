extends Label

const _MAX_DEVICE_ID = 100

# Array of arrays: The inner array is [device id, device text]
var _data = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialSearchForDevices()
	_rebuild_text()
	ConnectTo.orDie(Input,"joy_connection_changed", self, "_updateJoystickInfo")

func _initialSearchForDevices():
	var missing_device_count = 0
	for device_id in _MAX_DEVICE_ID:
		if Input.is_joy_known(device_id):
			_data.append([device_id, _build_text(device_id)])
			missing_device_count = 0
		else:
			++missing_device_count
		if missing_device_count >= 3:
			return

func _build_text(device_id) -> String:
	return "Joystick #" + device_id + ": " + Input.get_joy_guid(device_id)

# Find the index for the device_id in _data
func _find_index(device_id) -> int:
	for i in _data.size():
		var record = _data[i]
		if record[i] == device_id:
			return i
	return -1  # Not Found

func _find_insertion_point(device_id :int) -> int:
	return _data.size()

func _updateJoystickInfo(device_id :int, connected :bool):
	if device_id >= 0:
		if connected:
			var device_text = _build_text(device_id)
			var index = _find_insertion_point(device_id)
			_data.insert(index, [device_id, device_text])
		else:
			var index = _find_index(device_id)
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
