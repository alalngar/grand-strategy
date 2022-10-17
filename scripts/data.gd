extends Node

var map_material : ShaderMaterial = load("res://res/map_material.tres")
var map_texture : CompressedTexture2D = load("res://data/map/map.bmp")
var map_image := map_texture.get_image()
var color_texture : ImageTexture
var color_image := Image.new()
var lookup_image := Image.new()

var countries := {}
var provinces := {}
var province_default := {
	"id": 0,
	"owner": "LND"
}

func update_province_file(province):
	var prov_file := FileAccess.open("res://data/map/provinces/%d.json" % province.id, FileAccess.WRITE)
	prov_file.store_string(JSON.stringify(province))

func get_lookup_at(pos):
	return lookup_image.get_pixelv(pos)

func get_province_at(pos):
	var color := map_image.get_pixelv(pos).to_rgba32()
	if color in provinces:
		return provinces[color]

func _interpret_province_data(data):
	data.id = int(data.id)
	data.owner = str(data.owner)

func _interpret_country_data(data):
	data.color = Color8(int(data.color[0]), int(data.color[1]), int(data.color[2]))

func _ready():
	var countries_file := FileAccess.open("res://data/countries.json", FileAccess.READ)
	var countries_json = JSON.parse_string(countries_file.get_as_text())
	
	for tag in countries_json:
		var data = countries_json[tag]
		_interpret_country_data(data)
		countries[tag] = data
	
	var colors_file := FileAccess.open("res://data/map/colors.csv", FileAccess.READ_WRITE)
	var csv := colors_file.get_csv_line()
	while csv.size() > 1:
		var color := Color8(csv[1].to_int(), csv[2].to_int(), csv[3].to_int())
		
		var prov_file := FileAccess.open("res://data/map/provinces/%d.json" % csv[0].to_int(), FileAccess.READ)
		var data = JSON.parse_string(prov_file.get_as_text())
		_interpret_province_data(data)
		provinces[color.to_rgba32()] = data
		
		csv = colors_file.get_csv_line()
	
	var width := map_texture.get_width()
	var height := map_texture.get_height()
	
	lookup_image.create(width, height, false, Image.FORMAT_RGB8)
	color_image.create(256, 256, false, Image.FORMAT_RGB8)
	
	for x in range(width):
		for y in range(height):
			var color = map_image.get_pixel(x, y)
			if not color.to_rgba32() in provinces:
				var data := province_default.duplicate()
				var id := provinces.size() + 1
				data.id = int(id)
				
				var prov_file := FileAccess.open("res://data/map/provinces/%d.json" % id, FileAccess.READ)
				if prov_file == null:
					prov_file = FileAccess.open("res://data/map/provinces/%d.json" % id, FileAccess.WRITE)
					prov_file.store_string(JSON.stringify(data))
				else:
					data = JSON.parse_string(prov_file.get_as_text())
				
				_interpret_province_data(data)
			
				var csv_data := [str(id), color.r8, color.g8, color.b8]
				colors_file.store_csv_line(csv_data)
				provinces[color.to_rgba32()] = data
			
			var province = provinces[color.to_rgba32()]
			lookup_image.set_pixel(x, y, Color8(province.id % 256, province.id / 256, 0))
	
	var lookup_texture := ImageTexture.create_from_image(lookup_image)
	map_material.set_shader_parameter("lookup_texture", lookup_texture)
	
	color_texture = ImageTexture.create_from_image(color_image)
	map_material.set_shader_parameter("color_texture", color_texture)
	
	update_map_color()

func update_map_color():
	var color = Color.WHITE
	for province in Data.provinces.values():
		color = Data.countries[province.owner].color
		color_image.set_pixel(province.id % 256, province.id / 256, color)
	color_texture.update(color_image)
