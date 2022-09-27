extends Node

signal province_selected(data)
signal build_building(data)
signal unit_selected()
signal set_map_mode(id)

var selected_province

var country := {}

func start():
	province_selected.connect(_province_selected)
	build_building.connect(_add_building)
	
	if multiplayer.is_server():
		Data.monthly_tick.connect(_monthly_tick)

func _province_selected(data):
	selected_province = data

func _add_building(data):
	if data == null or selected_province.buildings.has(data) or data.cost > country.treasury:
		return
	
	country.treasury -= data.cost
	selected_province.buildings.append(data)
	
	MPSync.country_treasury(country)
	MPSync.province_buildings(selected_province)

func _monthly_tick():
	for tag in Data.countries:
		var c = Data.countries[tag]
		for p in c.provinces:
			c.treasury += 1
			MPSync.country_treasury(c)
