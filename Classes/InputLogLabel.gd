extends Label


class LogEntry:
	var device: int
	var action: String
	var keycode: int
	var button_index: int
	var as_string: String
	
	func _init(event :InputEvent):
		device = event.device
		as_string = "Device #" + str(device)
	
var entries = []

func _ready():
	set_process_input(true)

func _process(dt):
	pass

func _input(event :InputEvent):
	var action = event as InputEventAction
	var key = event as InputEventKey
	var gesture = event as InputEventGesture
	var joy_button = event as InputEventJoypadButton
	var joy_motion = event as InputEventJoypadMotion
	if action:
		on_action(action)
	if key:
		on_key(key)
	if joy_button:
		on_joy_button(joy_button)
	rebuild_text()

func on_action(event :InputEventAction):
	if event.pressed:
		var entry = LogEntry.new(event)
		entry.action = event.action
		entry.as_string += ": Action: " + event.action
		entries.append(entry)
	else: # Action released
		var i = 0
		while i < entries.size():
			var entry = entries[i]
			if entry.device == event.device and entry.action == event.action:
				entries.remove(i)
			else:
				i += 1

func on_key(event :InputEventKey):
	if event.pressed:
		var found = false
		for i in entries.size():
			var entry = entries[i]
			if entry.device == event.device and entry.keycode == event.scancode:
				found = true
				break
		if not found:
			var entry = LogEntry.new(event)
			entry.keycode = event.scancode
			var key_text = (" \"" + char(event.unicode) + "\"") if event.unicode > 0 else ""
			entry.as_string += ": Key: " + str(event.scancode) + key_text
			entries.append(entry)
	else: # Key released
		var i = 0
		while i < entries.size():
			var entry = entries[i]
			if entry.device == event.device and  entry.keycode == event.scancode:
				entries.remove(i)
			else:
				i += 1

func on_joy_button(event :InputEventJoypadButton):
	if event.pressed:
		var entry = LogEntry.new(event)
		entry.button_index = event.button_index
		entry.as_string += ": Button #" + str(event.button_index)
		entries.append(entry)
	else: # Button released
		var i = 0
		while i < entries.size():
			var entry = entries[i]
			if entry.device == event.device and entry.button_index == event.button_index:
				entries.remove(i)
			else:
				i += 1

func rebuild_text():
	text = ""
	for entry in entries:
		text += ("" if text.empty() else "\n") + entry.as_string
