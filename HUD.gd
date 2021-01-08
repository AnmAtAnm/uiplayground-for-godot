extends Control


onready var _viewport = get_viewport()

# Called when the node enters the scene tree for the first time.
func _ready():
	_viewport.connect("size_changed", self, "_onViewportSizeChanged")
	_onViewportSizeChanged()

func _onViewportSizeChanged():
	var screenSize = get_node("LabelScreenSize") as Label
	screenSize.text = "Screen Size:\n" + str(_viewport.size.x) + "x" + str(_viewport.size.y)
