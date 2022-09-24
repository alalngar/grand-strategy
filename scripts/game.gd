extends Node

signal province_selected(data)
signal build_building(data)
signal unit_selected()

var selected_province

var country := {}

func start():
	province_selected.connect(_province_selected)
	build_building.connect(_add_building)
	
	if multiplayer.is_server():
		Data.monthly_tick.connect(_monthly_tick)

func _add_building(data):
	if data == null or selected_province.buildings.has(data) or data.cost > country.treasury:
		return
	country.treasury -= data.cost
	for modifier in data.modifiers:
		selected_province.modifiers[modifier] += data.modifiers[modifier]
	selected_province.buildings.append(data)
	
	MPSync.country_treasury(country)
	MPSync.province_modifiers(selected_province)
	MPSync.province_buildings(selected_province)

func _province_selected(data):
	selected_province = data

func _monthly_tick():
	for tag in Data.countries:
		var c = Data.countries[tag]
		for p in c.provinces:
			c.treasury += 0.1
			MPSync.country_treasury(c)
