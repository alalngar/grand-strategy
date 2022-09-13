extends Node

signal province_selected(data)
signal build_buildings(data)
var selected_province

var country := {}

var last_monthly_income = 0.0
var total_population = 0
var monthly_population = 0

func _ready():
	Data.monthly_tick.connect(_monthly_tick)
	province_selected.connect(_province_selected)
	build_buildings.connect(_add_building)

func _add_building(data):
	if data.cost > country.treasury and data != null:
		return
	if selected_province.buildings.size() >= 5:
		return
	country.treasury -= data.cost
	selected_province.buildings.append(data)

func _province_selected(data):
	selected_province = data

func _monthly_tick():
	var before = country.treasury	
	_collect_tax()
	_calc_pop()
	_calc_buildings()
	last_monthly_income = country.treasury - before

func _calc_pop():
	var last_population = total_population
	total_population = 0
	for province in country.provinces:
		province.population += (province.population / 1000.0) * 5.0
		total_population += province.population
	monthly_population = total_population - last_population

func _collect_tax():
	for province in country.provinces:
		var tax = ((float(province.population / 1000) + 0) / 12) * 1
		country.treasury += tax

func _calc_buildings():
	for province in country.provinces:
		for building in province.buildings:
			for modifier in building.modifiers:
				country.treasury += modifier["tax"]
