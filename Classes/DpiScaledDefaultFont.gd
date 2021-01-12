extends Control

export(DynamicFont) var font
export(float, 1, 288, 1.0) var font_size_points: float = 16.0
# TODO: Minimum font size as % of viewport height

# Called when the node enters the scene tree for the first time.
func _ready():
	var dpi = OS.get_screen_dpi()
	
	if font:
		# Find the closest theme definition, falling back on the default theme
		if not theme:
			theme = Theme.new()
			theme.copy_default_theme()  # Fallback
			var parent = get_parent()
			while parent:
				var parent_theme = parent.theme as Theme
				if parent_theme:
					theme.copy_theme(parent_theme)
					break
				else:
					parent = parent.get_parent()
		theme.default_font = font;
		font.size = floor(dpi * font_size_points / 72)
	else:
		printerr("DpiScaledDefaultFont missing DynamicFont")
