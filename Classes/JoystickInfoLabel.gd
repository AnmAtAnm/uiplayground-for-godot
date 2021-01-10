extends Label

const _MAX_DEVICE_ID = 100

class DeviceInfo:
	var id :int
	var guid :String
	var description :String
	
	func _init(id):
		self.id = id
		self.guid = Input.get_joy_guid(id)
		self.description = _build_description(id)
		
	func _build_description(device_id) -> String:
		return "Joystick #" + str(device_id) + ": " + Input.get_joy_guid(device_id)

# Array of arrays: The inner array is [device id, guid, device text]
var _data = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialSearchForDevices()
	_rebuild_text()
	ConnectTo.orDie(Input,"joy_connection_changed", self, "_updateJoystickInfo")

func _input(event :InputEvent):
	var joy = event as InputEventJoypadButton
	if joy:
		var device_id = joy.device
		var index = _find_index(device_id)
		if index == -1:
			_data.append(DeviceInfo.new(device_id))
			_rebuild_text()

func _initialSearchForDevices():
	for device_id in _MAX_DEVICE_ID:
		if Input.is_joy_known(device_id) and not Input.get_joy_guid(device_id).empty():
			_data.append(DeviceInfo.new(device_id))

# Find the index for the device_id in _data
func _find_index(device_id) -> int:
	var guid = Input.get_joy_guid(device_id)
	for i in _data.size():
		var info = _data[i]
		if info.id == device_id and info.guid == guid:
			return i
	return -1  # Not Found

func _find_insertion_point(device_id :int) -> int:
	return _data.size()

func _updateJoystickInfo(device_id :int, connected :bool):
	if device_id >= 0:
		var index = _find_index(device_id)
		if connected and index > -1:
			_data.insert(index, DeviceInfo.new(device_id))
		else:
			if index != -1:
				_data.remove(-1)
	_rebuild_text()

func _rebuild_text():
	if _data.empty():
		text = "No joystick devices."
	else:
		text = ""
		for info in _data:
			text += ("" if text.empty() else "\n") + info.description
