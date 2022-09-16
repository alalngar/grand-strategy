extends Node

signal province_selected(data)
signal build_building(data)

var selected_province

var country := {}

func start():
	province_selected.connect(_province_selected)
	build_building.connect(_add_building)
	
	if not multiplayer.is_server(): return
	Data.monthly_tick.connect(_monthly_tick)

func _add_building(data):
	if data == null or data.cost > country.treasury:
		return
	country.treasury -= data.cost
	for modifier in data.modifiers:
		selected_province.modifiers[modifier] += data.modifiers[modifier]
	selected_province.buildings.append(data)

func _province_selected(data):
	selected_province = data

func _monthly_tick():
	for tag in Data.countries:
		var c = Data.countries[tag]
		for p in c.provinces:
			var growth = float(p.population) * (0.02 / 12.0)
			p.population += growth
			MPSync.prov_pop(p)
		for p in c.provinces:
			var tax = float(p.population / 1000) / 6.0
			c.treasury += tax + (tax * p.modifiers["local_tax"])
			MPSync.country_treasury(c)
