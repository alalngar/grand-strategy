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

func _ready():
	_update_info()
	flag_tex.texture = Game.country.flag
	
	Game.province_selected.connect(_update_prov)
	Data.daily_tick.connect(_daily_tick)
	province_close_btn.pressed.connect(func(): Game.province_selected.emit(null))
	
	pause_time_btn.pressed.connect(_pause_timer)
	increase_speed_btn.pressed.connect(_increase_speed)
	decrease_speed_btn.pressed.connect(_decrease_speed)
	
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
		return
	province_panel.visible = true
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
