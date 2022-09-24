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

const PROVINCE_MODIFIERS := {
	"local_tax": 0.0
}

# maybe set_process(false) instead of the constant is_server check
func _process(delta):
	if not multiplayer.is_server():
		return
		
	if year == 0:
		_set_date.rpc(total_days)
	
	if time_paused:
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
	return "%d-%d-%d" % [day, month, year]

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
	
	return "%d %s %d" % [day, _month, year]

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
	
	for b in buildings_json:
		var building = buildings_json[b]
		building.cost = int(building.cost)
		buildings[b] = building
	
	for p in provinces_json:
		var province = provinces_json[p]
		province.id = p.to_int()
		province.color = Color8(int(province.color[0]), int(province.color[1]), int(province.color[2]))
		province.owner = str(province.owner)
		province.development = float(province.development)
		province.center = Vector2i(int(province.center[0]), int(province.center[1]))
		province.buildings = []
		province.modifiers = PROVINCE_MODIFIERS
		provinces[province.color] = province
	
	for c in countries_json:
		var country = countries_json[c]
		country.color = Color8(int(country.color[0]), int(country.color[1]), int(country.color[2]))
		country.tag = c
		country.provinces = []
		country.treasury = 0
		country.flag = load("res://gfx/flags/%s.png" % c)
		if country.flag == null: country.flag = load("res://gfx/flags/default.png")
		countries[c] = country
	
	for c in countries:
		var country = countries[c]
		for p in provinces:
			var province = provinces[p]
			if province.owner == c:
				country.provinces.append(province)
