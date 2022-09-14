extends Node

signal province_selected(data)
signal build_building(data)

var selected_province

var country := {}

func start():
	if not multiplayer.is_server(): return
	
	Data.monthly_tick.connect(_monthly_tick)
	province_selected.connect(_province_selected)
	build_building.connect(_add_building)

func _add_building(data):
	if data.cost > country.treasury and data != null:
		return
	country.treasury -= data.cost
	selected_province.buildings.append(data)

func _province_selected(data):
	selected_province = data

func _monthly_tick():
	for tag in Data.countries:
		var c = Data.countries[tag]
		for province in c.provinces:
			province.population += (province.population / 1000.0) * 0.5
		for province in c.provinces:
			country.treasury += ((float(province.population / 1000) + 0) / 6) * 1

func _calc_buildings():
	for province in country.provinces:
		for building in province.buildings:
			for modifier in building.modifiers:
				country.treasury += modifier["tax"]
