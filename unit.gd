extends Control

var selected := false

func _ready():
	Game.unit_selected.connect(_deselect)

func _deselect():
	selected = false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Game.unit_selected.emit()
			selected = true

func _unhandled_input(event):
	if selected:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				position = get_global_mouse_position()
