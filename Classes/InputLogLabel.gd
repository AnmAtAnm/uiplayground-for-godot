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
	
var key_entries = []
var mouse_entries = []
var joy_entries = []
var action_entries = []

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
		action_entries.append(entry)
	else: # Action released
		var i = 0
		while i < action_entries.size():
			var entry = action_entries[i]
			if entry.device == event.device and entry.action == event.action:
				action_entries.remove(i)
			else:
				i += 1

func on_key(event :InputEventKey):
	if event.pressed:
		var found = false
		for i in key_entries.size():
			var entry = key_entries[i]
			if entry.device == event.device and entry.keycode == event.scancode:
				found = true
				break
		if not found:
			var entry = LogEntry.new(event)
			entry.keycode = event.scancode
			var key_text = (" \"" + char(event.unicode) + "\"") if event.unicode > 0 else ""
			entry.as_string += ": Key: " + str(event.scancode) + key_text
			key_entries.append(entry)
	else: # Key released
		var i = 0
		while i < key_entries.size():
			var entry = key_entries[i]
			if entry.device == event.device and  entry.keycode == event.scancode:
				key_entries.remove(i)
			else:
				i += 1

func on_joy_button(event :InputEventJoypadButton):
	if event.pressed:
		var entry = LogEntry.new(event)
		entry.button_index = event.button_index
		entry.as_string += ": Button #" + str(event.button_index)
		joy_entries.append(entry)
	else: # Button released
		var i = 0
		while i < joy_entries.size():
			var entry = joy_entries[i]
			if entry.device == event.device and entry.button_index == event.button_index:
				joy_entries.remove(i)
			else:
				i += 1

func rebuild_text():
	text = ""
	for entry in key_entries:
		text += ("" if text.empty() else "\n") + entry.as_string
	for entry in mouse_entries:
		text += ("" if text.empty() else "\n") + entry.as_string
	for entry in joy_entries:
		text += ("" if text.empty() else "\n") + entry.as_string
	for entry in action_entries:
		text += ("" if text.empty() else "\n") + entry.as_string
