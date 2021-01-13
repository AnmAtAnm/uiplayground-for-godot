extends VBoxContainer

const LEFT_STICK = 0
const RIGHT_STICK = 1
const TRIGGERS = 2

const ACTIVITY_DISPLAY_DELAY = 3000
const EPSILON = 0.006

class AxisPairStatus:
	var device_id :int
	var axis1_id: int
	var axis2_id: int
	var format: String
	var last_activity_msec = -ACTIVITY_DISPLAY_DELAY
	var output = Label.new()
	
	func _init(device_id, device_part):
		self.device_id = device_id
		output.visible = false
		
		var prefix = "Joy #" + str(device_id)
		match device_part:
			LEFT_STICK:
				format += prefix + ": Left Stick: %1.2f x %1.2f"
				axis1_id = JOY_ANALOG_LX
				axis2_id = JOY_ANALOG_LY
			RIGHT_STICK:
				format += prefix + ": Right Stick: %1.2f x %1.2f"
				axis1_id = JOY_ANALOG_RX
				axis2_id = JOY_ANALOG_RY
			TRIGGERS:
				format += prefix + ": Triggers: Left %1.2f, Right %1.2f"
				axis1_id = JOY_ANALOG_L2
				axis2_id = JOY_ANALOG_R2
	
	func update(now):
		var axis1 = Input.get_joy_axis(device_id, axis1_id)
		var axis2 = Input.get_joy_axis(device_id, axis2_id)
		
		output.text = format % [axis1, axis2]
		
		if axis1 < -EPSILON or axis1 > EPSILON or axis2 < -EPSILON or axis2 > EPSILON:
			output.visible = true
			last_activity_msec = now
		else:
			var dt = now - last_activity_msec
			output.visible = dt < ACTIVITY_DISPLAY_DELAY

onready var joy_detector = get_node("/root/JoyDetector")

var _statuses = []

func _ready():
	for device_id in joy_detector.device_ids:
		_add_device(device_id)
	ConnectTo.orDie(joy_detector, "joy_connection_changed", self, "_on_joy_connection_change")

func _on_joy_connection_change(device_id :int, connected :bool):
	var existing = null
	var i = 0
	while i < _statuses.size():
		var status = _statuses[i]
		if status.device_id == device_id:
			existing = status
			break
		i += 1

	if connected and not existing:
		_add_device(device_id)
	if not connected and existing:
		remove_child(existing.output)
		_statuses.remove(i)
		while i < _statuses.size():
			var status = _statuses[i] as AxisPairStatus
			if status.device_id == device_id:
				remove_child(status.output)
				_statuses.remove(i)
			else:
				i += 1

func _add_device(device_id):
	var status = AxisPairStatus.new(device_id, LEFT_STICK)
	_statuses.append(status)
	add_child(status.output)
	status = AxisPairStatus.new(device_id, RIGHT_STICK)
	_statuses.append(status)
	add_child(status.output)
	status = AxisPairStatus.new(device_id, TRIGGERS)
	_statuses.append(status)
	add_child(status.output)

func _process(_dt):
	var now = OS.get_ticks_msec()
	for status in _statuses:
		status.update(now)
