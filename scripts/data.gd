extends Node

var has_started := false
var dev_mode := false
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
var religions := {}
var cultures := {}
var units := {}

var pathfinding = AStar2D.new()

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
	_read_files()

func _read_files():
	var file = FileAccess.open("res://map/provinces.json", FileAccess.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	
	file = FileAccess.open("res://map/countries.json", FileAccess.READ)
	var countries_json = JSON.parse_string(file.get_as_text())
	
	file = FileAccess.open("res://common/buildings.json", FileAccess.READ)
	var buildings_json = JSON.parse_string(file.get_as_text())
	
	file = FileAccess.open("res://common/religions.json", FileAccess.READ)
	var religions_json = JSON.parse_string(file.get_as_text())
	
	file = FileAccess.open("res://common/cultures.json", FileAccess.READ)
	var cultures_json = JSON.parse_string(file.get_as_text())
	
	for b in buildings_json:
		var building = buildings_json[b]
		building.cost = int(building.cost)
		buildings[b] = building
	
	for r in religions_json:
		var religion = religions_json[r]
		religion.color = Color8(int(religion.color[0]), int(religion.color[1]), int(religion.color[2]))
		religion.name = r
		religions[r] = religion
	
	for r in cultures_json:
		var culture = cultures_json[r]
		culture.color = Color8(int(culture.color[0]), int(culture.color[1]), int(culture.color[2]))
		culture.name = r
		cultures[r] = culture
	
	# maybe add neighboring countries
	for c in countries_json:
		var country = countries_json[c]
		country.color = Color8(int(country.color[0]), int(country.color[1]), int(country.color[2]))
		country.tag = c
		country.provinces = []
		country.treasury = 0
		country.flag = load("res://gfx/flags/%s.png" % c)
		if country.flag == null: country.flag = load("res://gfx/flags/default.png")
		countries[c] = country
		units[c] = []
	
	for p in provinces_json:
		var province = provinces_json[p]
		province.id = p.to_int()
		province.color = Color8(int(province.color[0]), int(province.color[1]), int(province.color[2]))
		province.owner = countries[province.owner]
		province.development = float(province.development)
		province.center = Vector2i(int(province.center[0]), int(province.center[1]))
		province.religion = religions[province.religion]
		province.culture = cultures[province.culture]
		province.buildings = []
		province.neighbors = []
		provinces[province.color] = province
		
		pathfinding.add_point(province.id, province.center)
	
	for country in countries.values():
		for province in provinces.values():
			if province.owner.tag == country.tag:
				country.provinces.append(province)
	
	units["CYD"].append({
		"position": Vector2(352, 620),
		"origin": 0,
		"destination": 3,
		"in_move": false,
		"selected": false,
	})

# todo: make this update the Data.provinces
# mainly for dev mode or maybe a console command
func reload_prov_file():
	pass

func connect_points():
	for province in provinces.values():
		for id in province.neighbors:
			pathfinding.connect_points(province.id, id)
