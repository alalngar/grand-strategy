extends Node

signal selected_province(data)
signal monthly_income(data)

var country := {}

func _ready():
	Data.monthly_tick.connect(_monthly_tick)

func _monthly_tick():
	_calc_tax()

func _calc_tax():
	var _monthly_income = 0.0
	for province in Game.country.provinces:
		# (((pop / 1000) + extra) / 12) * efficiency
		var tax = ((float(province.population / 1000) + 0) / 12) * 1
		Game.country.treasury += tax
		_monthly_income += tax
	monthly_income.emit(_monthly_income)
