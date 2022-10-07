extends Control

@onready var flag_tex := $TopPanel/Flag
@onready var income_lbl := $TopPanel/HB2/Income
@onready var decrease_speed_btn := $TopPanel/Time/HB/Decrease
@onready var increase_speed_btn := $TopPanel/Time/HB/Increase
@onready var pause_time_btn := $TopPanel/Time/HB/Pause
@onready var date_lbl := $TopPanel/Time/Date

@onready var province_panel := $ProvPanel
@onready var province_name_lbl := $ProvPanel/Name
@onready var province_owner_lbl := $ProvPanel/VB/Owner
@onready var province_control_lbl := $ProvPanel/VB/Control
@onready var province_religion_lbl := $ProvPanel/VB/Religion
@onready var province_culture_lbl := $ProvPanel/VB/Culture
@onready var province_dev_lbl := $ProvPanel/VB/Development
@onready var province_close_btn := $ProvPanel/Close

@onready var province_build_ui_open := $ProvPanel/BuildingButton
@onready var province_build_ui_close := $ProvPanel/BuildingPanel/Close
@onready var building_panel := $ProvPanel/BuildingPanel

@onready var nation_mode_btn := $MapPanel/HB/Nation
@onready var religion_mode_btn := $MapPanel/HB/Religion
@onready var culture_mode_btn := $MapPanel/HB/Culture

@onready var dev_prov_panel := $DevPanel
@onready var dev_create_prov_panel := $DevPanel/CreatePov
@onready var dev_prov_owner_led := $DevPanel/VB/Owner
@onready var dev_prov_religion_led := $DevPanel/VB/Religion
@onready var dev_prov_culture_led := $DevPanel/VB/Culture
@onready var dev_update_btn := $DevPanel/VB/Update
@onready var dev_create_btn := $"DevPanel/CreatePov/VB/Create Province"


var new_color
var center_pos

func _ready():
	_update_info()
	flag_tex.texture = Game.country.flag
	
	Game.province_selected.connect(_update_prov)
	Game.province_selected_unknown.connect(_update_prov_unknown)
	Data.daily_tick.connect(_daily_tick)
	province_close_btn.pressed.connect(func(): Game.province_selected.emit(null))
	
	pause_time_btn.pressed.connect(_pause_timer)
	increase_speed_btn.pressed.connect(_increase_speed)
	decrease_speed_btn.pressed.connect(_decrease_speed)
	dev_update_btn.pressed.connect(_update_dev_panel)
	dev_create_btn.pressed.connect(_create_province)
	province_build_ui_open.pressed.connect(_province_build_ui)
	province_build_ui_close.pressed.connect(_province_build_ui)
	
	nation_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(0))
	religion_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(1))
	culture_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(2))

func _process(delta):
	date_lbl.text = Data.get_date()

func _daily_tick():
	_update_info()

func _update_info():
	income_lbl.text = "%.0f$" % Game.country.treasury

func _update_prov(data):
	if data == null:
		province_panel.visible = false
		dev_prov_panel.visible = false
		return
	building_panel.visible = false
	province_build_ui_open.visible = true
	province_panel.visible = true
	province_name_lbl.text = tr("p%d" % data.id)
	province_owner_lbl.text = "Owner: %s" % tr(data.owner.tag)
	province_dev_lbl.text = "Development: %.0f" % data.development
	province_religion_lbl.text = "Religion: %s" % tr(data.religion.name)
	province_culture_lbl.text = "Culture: %s" % tr(data.culture.name)
	if Data.dev_mode:
		dev_prov_panel.visible = true
		dev_create_prov_panel.visible = false
		dev_prov_owner_led.text = data.owner.tag
		dev_prov_culture_led.text = data.culture.name
		dev_prov_religion_led.text = data.religion.name

func _pause_timer():
	# sync time pausing for other players
	Data.time_paused = !Data.time_paused
	pause_time_btn.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
	
func _province_build_ui():
	province_build_ui_open.visible = !province_build_ui_open.visible
	building_panel.visible = !building_panel.visible
	return

func _update_dev_panel():
	
	var file := FileAccess.open("res://map/provinces.json", FileAccess.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	
	var prov = provinces_json[str(Game.selected_province.id)]
	
	if(Data.religions.has(dev_prov_religion_led.text)):
		prov.religion = dev_prov_religion_led.text
	if(Data.cultures.has(dev_prov_culture_led.text)):
		prov.culture = dev_prov_culture_led.text
	if(Data.countries.has(dev_prov_owner_led.text)):
		prov.owner = dev_prov_owner_led.text
	file = FileAccess.open("res://map/provinces.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(provinces_json, "\t"))
	#add a way to change center position through mouse input
	
	# add this
	#Data.reload_prov_file()
func _update_prov_unknown(color, mouse):
	dev_prov_panel.visible = true
	dev_create_prov_panel.visible = true
	new_color = color
	center_pos = mouse

func _create_province():
	var max_num = 0
	var new_prov = {
		"center": [],
		"color": [],
		"culture": "",
		"development": 0,
		"owner": "",
		"religion": ""
	}
	var file := FileAccess.open("res://map/provinces.json", FileAccess.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	if !Data.dev_mode && dev_create_prov_panel.visible == true:
		return
	#Checks for any duplicate colors already in provinces.json
	for c in provinces_json:
		if provinces_json[c].color[0] == new_color.r8:
			if provinces_json[c].color[1] == new_color.g8:
				if provinces_json[c].color[2] == new_color.b8:
					dev_create_prov_panel.visible = false
					print("Province already exists")
					return
	#Checks for max number in provinces ignoring ocean tiles (over 2000 id)
	for p in provinces_json:
		if p.to_int() < 2000:
			if max_num < p.to_int():
				max_num = p.to_int()
	max_num += 1
	new_prov.religion = "none"
	new_prov.culture = "none"
	new_prov.owner = "LND"
	if(Data.religions.has(dev_prov_religion_led.text)):
		new_prov.religion = dev_prov_religion_led.text
	if(Data.cultures.has(dev_prov_culture_led.text)):
		new_prov.culture = dev_prov_culture_led.text
	if(Data.countries.has(dev_prov_owner_led.text)):
		new_prov.owner = dev_prov_owner_led.text
	new_prov.color = [new_color.r8, new_color.g8, new_color.b8]
	new_prov.center = [center_pos.x, center_pos.y]
	new_prov.development = 10
	provinces_json[max_num] = new_prov
	file = FileAccess.open("res://map/provinces.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(provinces_json, "\t", true))
	dev_prov_panel.visible = false
	dev_create_prov_panel.visible = false
