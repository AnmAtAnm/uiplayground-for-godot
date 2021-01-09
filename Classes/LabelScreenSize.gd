extends Label

export var cycle_orientation_on_click = false

onready var _viewport = get_viewport()

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	_viewport.connect("size_changed", self, "_onViewportSizeChanged")
	_onViewportSizeChanged()
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if cycle_orientation_on_click and event.button_index == BUTTON_LEFT and event.pressed:
			accept_event()
			print("------- @" + str(OS.get_unix_time()) + "\nwas: " + str(OS.screen_orientation))
			OS.screen_orientation = (OS.screen_orientation + 1) % 7
			print("now: " + str(OS.screen_orientation))
			ConnectTo.orDie(get_tree(),"idle_frame", self, "_onViewportSizeChanged", [], CONNECT_ONESHOT)


func _onViewportSizeChanged():
	var screen = OS.current_screen
	var newtext = "Viewport Size: " + str(_viewport.size.x) +  "x" + str(_viewport.size.y) 
	newtext += " @ " + str(OS.get_screen_dpi(screen)) + "dpi"
	match OS.screen_orientation:
		OS.SCREEN_ORIENTATION_LANDSCAPE:
			newtext += "\nLandscape"
		var orientation:
			newtext += "\nOrientation: " + str(orientation)
	text = newtext
