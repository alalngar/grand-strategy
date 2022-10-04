extends CanvasLayer

@onready var flag_tex := $UI/TopPanel/Flag
@onready var income_lbl := $UI/TopPanel/HB2/Income
@onready var decrease_speed_btn := $UI/TopPanel/Time/HB/Decrease
@onready var increase_speed_btn := $UI/TopPanel/Time/HB/Increase
@onready var pause_time_btn := $UI/TopPanel/Time/HB/Pause
@onready var date_lbl := $UI/TopPanel/Time/Date

@onready var province_panel := $UI/ProvPanel
@onready var province_name_lbl := $UI/ProvPanel/Name
@onready var province_owner_lbl := $UI/ProvPanel/VB/Owner
@onready var province_control_lbl := $UI/ProvPanel/VB/Control
@onready var province_religion_lbl := $UI/ProvPanel/VB/Religion
@onready var province_culture_lbl := $UI/ProvPanel/VB/Culture
@onready var province_dev_lbl := $UI/ProvPanel/VB/Development
@onready var province_close_btn := $UI/ProvPanel/Close

@onready var nation_mode_btn := $UI/MapPanel/HB/Nation
@onready var religion_mode_btn := $UI/MapPanel/HB/Religion
@onready var culture_mode_btn := $UI/MapPanel/HB/Culture


@onready var dev_mode_text := $"UI/Dev Mode"
@onready var dev_mode_box := $UI/DevPanel
@onready var dev_province_tag := $UI/DevPanel/VBoxContainer/provOwner
@onready var dev_province_religion := $UI/DevPanel/VBoxContainer/provReligion
@onready var dev_province_culture := $UI/DevPanel/VBoxContainer/provCulture
@onready var dev_update_button := $"UI/DevPanel/VBoxContainer/Update Province"
var prov_data

func _ready():
	_update_info()
	flag_tex.texture = Game.country.flag
	
	Game.province_selected.connect(_update_prov)
	Data.daily_tick.connect(_daily_tick)
	province_close_btn.pressed.connect(func(): Game.province_selected.emit(null))
	
	pause_time_btn.pressed.connect(_pause_timer)
	increase_speed_btn.pressed.connect(_increase_speed)
	decrease_speed_btn.pressed.connect(_decrease_speed)
	dev_update_button.pressed.connect(_dev_update_province)
	
	nation_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(0))
	religion_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(1))
	culture_mode_btn.pressed.connect(func(): Game.set_map_mode.emit(2))
	if Data.dev_mode_state == true:
		dev_mode_text.visible = true

func _process(delta):
	date_lbl.text = Data.get_date()

func _daily_tick():
	_update_info()

func _update_info():
	income_lbl.text = "%.0f$" % Game.country.treasury

func _update_prov(data):
	prov_data = data
	if data == null:
		province_panel.visible = false
		dev_mode_box.visible = false
		return
	province_panel.visible = true
	if Data.dev_mode_state == true:
		dev_mode_box.visible = true
	province_name_lbl.text = tr("p%d" % data.id)
	province_owner_lbl.text = "Owner: %s" % tr(data.owner.tag)
	province_dev_lbl.text = "Development: %.0f" % data.development
	province_religion_lbl.text = "Religion: %s" % data.religion.name
	province_culture_lbl.text = "Culture: %s" % data.culture.name

func _pause_timer():
	# sync time pausing for other players
	Data.time_paused = !Data.time_paused
	pause_time_btn.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
	
func _dev_update_province():
	var file := File.new()
	file.open("res://map/provinces.json", File.READ)
	var provinces_json = JSON.parse_string(file.get_as_text())
	file.close()
	if(Data.countries.has(dev_province_tag.text)):
		provinces_json["%s" % prov_data.id].owner = dev_province_tag.text
		Data.provinces[prov_data.color].owner = dev_province_tag.text
	if(Data.religions.has(dev_province_religion.text)):
		provinces_json["%s" % prov_data.id].religion = dev_province_religion.text
		Data.provinces[prov_data.color].religion = dev_province_religion.text
	if(Data.cultures.has(dev_province_culture.text)):
		provinces_json["%s" % prov_data.id].culture = dev_province_culture.text
		Data.provinces[prov_data.color].culture = dev_province_culture.text
	file.open("res://map/provinces.json", File.WRITE)
	file.store_line(JSON.stringify(provinces_json, "\t"))
	file.close()
	
	
		
