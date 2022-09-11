extends Sprite2D

@onready var map_image := texture.get_image()
@onready var lookup_image := Image.new()

func _ready():
	lookup_image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGB8)
	
	for x in range(texture.get_width()):
		for y in range(texture.get_height()):
			var province = Game.provinces[map_image.get_pixel(x, y)]
			if province == null:
				continue
			lookup_image.set_pixel(x, y, Color8(province.id % 256, province.id / 256, 0))
	
	var lookup_texture = ImageTexture.create_from_image(lookup_image)
	material.set_shader_parameter("lookup_texture", lookup_texture)
	
	var color_image := Image.new()
	color_image.create(256, 256, false, Image.FORMAT_RGB8)
	
	for key in Game.provinces:
		var province = Game.provinces[key]
		var color = Game.countries[province.owner].color
		color_image.set_pixel(province.id % 256, province.id / 256, color)
	
	var color_texture = ImageTexture.create_from_image(color_image)
	material.set_shader_parameter("color_texture", color_texture)

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		var lookup_color = lookup_image.get_pixelv(mouse_pos)
		material.set_shader_parameter("selected_color",  Vector4(lookup_color.r8, lookup_color.g8, lookup_color.b8, 255))
		
		var province = Game.provinces[map_image.get_pixelv(mouse_pos)]
		Game.selected_province.emit(province)
