extends Control

var idx := -1
var tag := ""

var data := {}

func _process(delta):
	data = Data.units[tag][idx]
	
	var x = data.position.x - 8
	var y = data.position.y - 8
	if x != position.x or y != position.y:
		position.x = x
		position.y = y

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			data.selected = true

func _unhandled_input(event):
	if data.selected:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				var mouse_pos = get_global_mouse_position()
				Game.unit_move.emit(data, mouse_pos)
