extends Sprite2D

func _ready():
	texture = Data.map_texture
	material = Data.map_material

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			
			var lookup_color = Data.get_lookup_at(mouse_pos)
			material.set_shader_parameter("selected_color", Vector4(lookup_color.r8, lookup_color.g8, lookup_color.b8, 255))
			
			var province = Data.get_province_at(mouse_pos)
			Game.province_selected.emit(province)
