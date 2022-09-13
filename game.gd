extends Node

signal selected_province(data)

var country := {}

var last_monthly_income = 0.0

func _ready():
	Data.monthly_tick.connect(_monthly_tick)

func _monthly_tick():
	_collect_tax()
	_calc_pop()

func _calc_pop():
	for province in country.provinces:
		province.population += (province.population / 1000.0) * 5.0

func _collect_tax():
	var before = country.treasury
	for province in country.provinces:
		var tax = ((float(province.population / 1000) + 0) / 12) * 1
		country.treasury += tax
	last_monthly_income = country.treasury - before
