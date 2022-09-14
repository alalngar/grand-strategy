extends Node

var has_started := false
const MULTIPLAYER_PORT = 56727

signal daily_tick()
signal monthly_tick()
signal yearly_tick()

var year := 0
var month := 0
var day := 0
var total_days := 388 * 360
var timer := 0.0
var time_paused := true
var time_speed := 1.0

var provinces := {}
var countries := {}
var buildings := {}

func _process(delta):
	if time_paused or not multiplayer.is_server():
		return
	
	timer += delta
	if timer >= time_speed:
		timer = 0.0
		total_days += 1
		_tick()

@rpc(call_local)
func _set_date(days):
	total_days = days
	day = days % 30 + 1
	month = days / 30 % 12 + 1
	year = days / 30 / 12 + 1

func _tick():
	var _day = day
	var _month = month
	var _year = year
	
	_set_date.rpc(total_days)
	
	if _day != day:
		daily_tick.emit()
	if _month != month:
		monthly_tick.emit()
	if _year != year:
		yearly_tick.emit()

func get_date():
	return "%d-%d-%d" % [year, month, day]

func get_date_extended():
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

func _ready():
	var file := File.new()
	
	file.open("res://map/provinces.json", File.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	file.close()
	
	file.open("res://map/countries.json", File.READ)
	var countries_json = JSON.parse_string(file.get_as_text())
	file.close()
	
	file.open("res://common/buildings.json", File.READ)
	var buildings_json = JSON.parse_string(file.get_as_text())
	file.close()
	
	for building in buildings_json:
		var data := {}
		data.id = int(building.id)
		data.cost = int(building.cost)
		data.modifiers = building.modifiers
		buildings[data.id] = data
	
	for province in provinces_json:
		var data := {}
		data.color = Color8(int(province.color[0]), int(province.color[1]), int(province.color[2]))
		data.id = int(province.id)
		data.owner = str(province.owner)
		data.population = float(province.population)
		data.buildings = []
		provinces[data.color] = data
	
	for country in countries_json:
		var data := {}
		data.color = Color8(int(country.color[0]), int(country.color[1]), int(country.color[2]))
		data.tag = str(country.tag)
		data.provinces = []
		data.treasury = 0
		data.flag = load("res://gfx/flags/%s.png" % country.tag)
		if data.flag == null:
			data.flag = load("res://gfx/flags/default.png")
		for key in provinces:
			var province = provinces[key]
			if province.owner == data.tag:
				data.provinces.append(province)
		countries[data.tag] = data
