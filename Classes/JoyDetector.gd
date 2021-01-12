extends Node


const _MAX_SEARCH_DEVICE_ID = 100

# Drop-in replacement for Input signal "joy_connection_changed"
signal joy_connection_changed(device_id, connected)

class JoyDevice:
	var id: int
	var guid: String
	
	func _init(device_id :int, guid :String):
		self.id = device_id
		self.guid = guid

# Array of devices for external consumption
var device_ids = []

# Array of JoyDevice for internal identification
var _devices = []

func _init():
	pause_mode = PAUSE_MODE_PROCESS

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialSearchForDevices()
	ConnectTo.orDie(Input,"joy_connection_changed", self, "_on_input_joy_connection_changed")

func _initialSearchForDevices():
	for device_id in _MAX_SEARCH_DEVICE_ID:
		if Input.is_joy_known(device_id):
			var guid = Input.get_joy_guid(device_id)
			if not guid.empty():
				_add_device(device_id, guid)

func _on_input_joy_connection_changed(device_id :int, connected :bool):
	# Ignore connected.  Just compare to previous state
	var guid = Input.get_joy_guid(device_id)
	var index = _find_index_for_id(device_id)
	if index == -1:
		if not guid.empty():
			_add_device(device_id, guid)
	else:
		var old_device = _devices[index]
		if guid.empty():
			_remove_device(index, old_device)
		else:
			var old_guid = old_device.guid
			if guid != old_guid:
				# Old device was replaced, but something is still connected.
				old_device.guid = guid
				emit_signal("joy_connection_changed", device_id, true)

func _input(event :InputEvent):
	var joy_event = event as InputEventJoypadButton
	if joy_event:
		var device_id = joy_event.device
		var index = _find_index_for_id(device_id)
		if index == -1:
			_add_device(device_id, Input.get_joy_guid(index))
	

# Find the index for the device_id in _data
func _find_index_for_id(device_id :int) -> int:
	for i in _devices.size():
		var device = _devices[i]
		if device.id == device_id:
			return i
				
	return -1  # Not Found

func _add_device(device_id :int, guid: String):
	device_ids.append(device_id)
	device_ids.sort()
	
	_devices.append(JoyDevice.new(device_id, guid))
	emit_signal("joy_connection_changed", device_id, true)

func _remove_device(index :int, old_device :JoyDevice):
	_devices.remove(index)
	
	var id_index = device_ids.find(old_device.id)
	if id_index != -1:
		device_ids.remove(id_index)
		device_ids.sort()
		
		# Only emit if there is a public change
		emit_signal("joy_connection_changed", old_device.id, false)
