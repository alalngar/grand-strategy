extends Node

@onready var unit_scene := load("res://unit.tscn")

signal province_selected(data)
signal province_selected_unknown(data)
signal build_building(data)
signal unit_move(data, pos)
signal set_map_mode(id)

var selected_province

var country := {}

func start():
	_create_units()
	province_selected.connect(_province_selected)
	build_building.connect(_add_building)
	
	if multiplayer.is_server():
		Data.daily_tick.connect(_daily_tick)
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

func _daily_tick():
	for units in Data.units.values():
		for i in range(units.size()):
			var unit = units[i]
			if unit.in_move:
				if unit.origin != unit.destination:
					var id_path = Data.pathfinding.get_id_path(unit.origin, unit.destination)
					var pos_path = Data.pathfinding.get_point_path(unit.origin, unit.destination)
					unit.origin = id_path[1]
					unit.position = pos_path[1]
					if unit.origin == unit.destination:
						unit.in_move = false
	MPSync.country_units(country)

func _monthly_tick():
	for tag in Data.countries:
		var c = Data.countries[tag]
		for p in c.provinces:
			c.treasury += 1
			MPSync.country_treasury(c)

func _create_units():
	for tag in Data.units:
		var units = Data.units[tag]
		if not units.is_empty():
			for i in range(units.size()):
				var scene = unit_scene.instantiate()
				scene.idx = i
				scene.tag = tag
				add_child(scene)
