extends Node

signal selected_province(data)

var provinces := {}
var countries := {}

func _ready() -> void:
	var file := File.new()
	
	file.open("res://map/provinces.json", File.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	file.close()
	
	file.open("res://map/countries.json", File.READ)
	var countries_json = JSON.parse_string(file.get_as_text())
	file.close()
	
	for province in provinces_json:
		var data := {}
		data.color = Color8(int(province.color[0]), int(province.color[1]), int(province.color[2]))
		data.id = int(province.id)
		data.owner = int(province.owner)
		provinces[data.color] = data
	
	for country in countries_json:
		var data := {}
		data.color = Color8(int(country.color[0]), int(country.color[1]), int(country.color[2]))
		data.id = int(country.id)
		countries[data.id] = data
