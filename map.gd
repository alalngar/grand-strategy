extends Sprite2D

@onready var map_image := texture.get_image()
@onready var lookup_image := Image.new()
@onready var color_image := Image.new()
var color_texture

func _ready():
	lookup_image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGB8)
	color_image.create(256, 256, false, Image.FORMAT_RGB8)
	
	for x in range(texture.get_width()):
		for y in range(texture.get_height()):
			var province = Data.provinces[map_image.get_pixel(x, y)]
			if province == null:
				continue
			lookup_image.set_pixel(x, y, Color8(province.id % 256, province.id / 256, 0))
	
	var lookup_texture = ImageTexture.create_from_image(lookup_image)
	material.set_shader_parameter("lookup_texture", lookup_texture)
	color_texture = ImageTexture.create_from_image(color_image)
	material.set_shader_parameter("color_texture", color_texture)
	
	_refresh_map()

func _refresh_map():
	for key in Data.provinces:
		var province = Data.provinces[key]
		var color = Data.countries[province.owner].color
		color_image.set_pixel(province.id % 256, province.id / 256, color)
	
	color_texture.update(color_image)

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos := get_global_mouse_position()
		var color := map_image.get_pixelv(mouse_pos)
		if color != Color.BLACK:
			var lookup_color := lookup_image.get_pixelv(mouse_pos)
			material.set_shader_parameter("selected_color", Vector4(lookup_color.r8, lookup_color.g8, lookup_color.b8, 255))
			
			var province = Data.provinces[color]
			Game.selected_province.emit(province)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_pos := get_global_mouse_position()
		var color := map_image.get_pixelv(mouse_pos)
		if color != Color.BLACK:
			Data.provinces[color].owner = int(Input.is_key_pressed(KEY_CTRL)) + 2
			_refresh_map()
