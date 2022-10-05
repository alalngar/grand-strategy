extends Sprite2D

# TODO: move all map stuff into the Data or Game script

@onready var map_image := texture.get_image()
@onready var lookup_image := Image.new()
@onready var color_image := Image.new()

var color_texture

var mouse_pos := Vector2.ZERO

func _ready():
	Game.unit_move.connect(_unit_move)
	Game.province_selected.connect(_update_selection)
	Game.set_map_mode.connect(_set_map_mode)
	lookup_image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGB8 | Image.INTERPOLATE_NEAREST)
	color_image.create(256, 256, false, Image.FORMAT_RGB8 | Image.INTERPOLATE_NEAREST)
	
	var previous_province = {}
	var previous_id = 0
	for y in range(texture.get_height()):
		for x in range(texture.get_width()):
			var color = map_image.get_pixel(x, y)
			if not Data.provinces.has(color):
				continue
			var province = Data.provinces[color]
			lookup_image.set_pixel(x, y, Color8(province.id % 256, province.id / 256, 0))
			
			# set province neighbors
			# maybe delegate to data
			if previous_id != province.id and previous_province:
				if not previous_province.neighbors.has(province.id):
					previous_province.neighbors.append(province.id)
				if not province.neighbors.has(previous_id):
					province.neighbors.append(previous_id)
			previous_id = province.id
			previous_province = province
	
	Data.connect_points()
	
	var lookup_texture = ImageTexture.create_from_image(lookup_image)
	material.set_shader_parameter("lookup_texture", lookup_texture)
	
	color_texture = ImageTexture.create_from_image(color_image)
	material.set_shader_parameter("color_texture", color_texture)
	
	_set_map_mode(0)

func _update_map_mode(id):
	var color = Color.WHITE
	for province in Data.provinces.values():
		match id:
			0: color = province.owner.color
			1: color = province.religion.color
			2: color = province.culture.color
		color_image.set_pixel(province.id % 256, province.id / 256, color)
	color_texture.update(color_image)

func _set_map_mode(id):
	_update_map_mode(id)

func _update_selection(data):
	if data == null:
		material.set_shader_parameter("selected_color", Vector4(0, 0, 0, 0))
		return
	var lookup_color := lookup_image.get_pixelv(mouse_pos)
	material.set_shader_parameter("selected_color", Vector4(lookup_color.r8, lookup_color.g8, lookup_color.b8, 255))

func _process(delta):
	mouse_pos = get_global_mouse_position()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var color := map_image.get_pixelv(mouse_pos)
			if color != Color.BLACK:
				if(!Data.provinces.has(color)):
					return
				var province = Data.provinces[color]
				Game.province_selected.emit(province)
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			Game.province_selected.emit(null)

func _unit_move(data, pos):
	var color := map_image.get_pixelv(pos)
	if color != Color.BLACK:
		var province = Data.provinces[color]
		data.destination = province.id
		data.in_move = data.origin != data.destination
