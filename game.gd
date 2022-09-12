extends Node

signal selected_province(data)

var country := {}

func _ready():
	Data.daily_tick.connect(_daily_tick)

func _daily_tick():
	_calc_tax()

func _calc_tax():
	for province in Game.country.provinces:
		# (((pop / 1000) + extra) / 12) * efficiency
		var tax = ((float(province.population / 1000) + 0) / 12) * 1
		Game.country.treasury += tax
