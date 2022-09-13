extends Sprite2D

@onready var map_image := texture.get_image()
@onready var lookup_image := Image.new()
@onready var color_image := Image.new()
var color_texture

var mouse_pos := Vector2.ZERO

func _ready():
	Game.province_selected.connect(_update_selection)
	lookup_image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGB8)
	color_image.create(256, 256, false, Image.FORMAT_RGB8)
	
	for x in range(texture.get_width()):
		for y in range(texture.get_height()):
			var color = map_image.get_pixel(x, y)
			if not Data.provinces.has(color):
				continue
			var province = Data.provinces[color]
			lookup_image.set_pixel(x, y, Color8(province.id % 256, province.id / 256, 0))
	
	var lookup_texture = ImageTexture.create_from_image(lookup_image)
	material.set_shader_parameter("lookup_texture", lookup_texture)
	color_texture = ImageTexture.create_from_image(color_image)
	material.set_shader_parameter("color_texture", color_texture)
	
	_refresh_map()

func _update_selection(data):
	if data == null:
		material.set_shader_parameter("selected_color", Vector4(0, 0, 0, 0))
		return
	var lookup_color := lookup_image.get_pixelv(mouse_pos)
	material.set_shader_parameter("selected_color", Vector4(lookup_color.r8, lookup_color.g8, lookup_color.b8, 255))

func _refresh_map():
	for key in Data.provinces:
		var province = Data.provinces[key]
		var color = Data.countries[province.owner].color
		color_image.set_pixel(province.id % 256, province.id / 256, color)
	
	color_texture.update(color_image)

func _process(delta):
	mouse_pos = get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var color := map_image.get_pixelv(mouse_pos)
			if color != Color.BLACK:
				var province = Data.provinces[color]
				Game.province_selected.emit(province)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var color := map_image.get_pixelv(mouse_pos)
			if color != Color.BLACK:
				if Input.is_key_pressed(KEY_CTRL):
					Data.provinces[color].owner = Game.country.tag
				else:
					Game.country = Data.countries[Data.provinces[color].owner]
				_refresh_map()
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			Game.province_selected.emit(null)
