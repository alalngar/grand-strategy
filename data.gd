extends Node

signal daily_tick()
signal monthly_tick()

var year := 0
var month := 0
var day := 0
var total_days := 388 * 360
var timer := 0.0
var time_paused := false
var time_speed := 1.0

var provinces := {}
var countries := {}

func _process(delta):
	if time_paused:
		return
	timer += delta
	if timer >= time_speed:
		timer = 0.0
		total_days += 1
		_tick()

func _set_date():
	var _day = day
	var _month = month
	var _year = year
	
	day = total_days % 30 + 1
	month = total_days / 30 % 12 + 1
	year = total_days / 30 / 12 + 1
	
	if _day != day:
		daily_tick.emit()
	if _month != month:
		monthly_tick.emit()

func _tick():
	_set_date()

func get_date():
	return "%d-%d-%d" % [year, month, day]

func get_date_extended():
	var _day = str(day)
	if _day.ends_with("11") or _day.ends_with("12") or _day.ends_with("13"):
		_day += "th"
	elif _day.ends_with("1"):
		_day += "st"
	elif _day.ends_with("2"):
		_day += "nd"
	elif _day.ends_with("3"):
		_day += "rd"
	else:
		_day += "th"
	
	var _month = "Month"
	match month:
		1 : _month = "January"
		2 : _month = "February"
		3 : _month = "March"
		4 : _month = "April"
		5 : _month = "May"
		6 : _month = "June"
		7 : _month = "July"
		8 : _month = "August"
		9 : _month = "September"
		10: _month = "October"
		11: _month = "November"
		12: _month = "December"
	
	return "%s %s %d" % [day, _month, year]

func _set_country():
	Game.country = countries[2]

func _ready():
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
		data.population = int(province.population)
		provinces[data.color] = data
	
	for country in countries_json:
		var data := {}
		data.color = Color8(int(country.color[0]), int(country.color[1]), int(country.color[2]))
		data.id = int(country.id)
		data.provinces = []
		data.treasury = 0
		for key in provinces:
			var province = provinces[key]
			if province.owner == data.id:
				data.provinces.append(province)
		countries[data.id] = data
	
	_set_country()
	_set_date()
