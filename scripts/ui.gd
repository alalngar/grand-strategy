extends CanvasLayer

@onready var bb_scene := preload("res://building_button.tscn")

@onready var prov_panel := $UI/ProvPanel
@onready var prov_close = $UI/ProvPanel/Close
@onready var prov_name := $UI/ProvPanel/VB1/Province
@onready var prov_pop := $UI/ProvPanel/VB1/Population

@onready var prov_build_1 := $UI/ProvPanel/VB2/GridContainer/Button1

@onready var info_treasury := $UI/InfoPanel/MC/HB/VB1/HB/Gold
@onready var info_income := $UI/InfoPanel/MC/HB/VB1/Income
@onready var info_total_pop := $UI/InfoPanel/MC/HB/VB2/HB/Pop
@onready var info_monthly_pop := $UI/InfoPanel/MC/HB/VB2/Growth
@onready var info_flag := $UI/NewUIPanel/Flag

@onready var time_date := $UI/TimePanel/Date
@onready var time_increase = $UI/TimePanel/HB/Increase
@onready var time_decrease = $UI/TimePanel/HB/Decrease
@onready var time_pause = $UI/TimePanel/HB/Pause

func _ready():
	Game.province_selected.connect(_selected_province)
	Data.daily_tick.connect(_update_province_panel)
	time_increase.pressed.connect(_increase_speed)
	time_decrease.pressed.connect(_decrease_speed)
	time_pause.pressed.connect(_pause_timer)
	prov_build_1.pressed.connect(_build_building.bind("church"))

func _process(delta):
	time_date.text = Data.get_date_extended()
	info_treasury.text = "%.1f" % Game.country.treasury
	info_flag.texture = Game.country.flag
	_update_province_panel()

func _selected_province(data):
	prov_panel.visible = false if data == null else true
	print(data)

func _deselect_province():
	Game.province_selected.emit(null)

func _update_province_panel():
	if Game.selected_province:
		prov_name.text = tr("p" + str(Game.selected_province.id))
		prov_pop.text = "Population: %.0f" % Game.selected_province.population

func _pause_timer():
	Data.time_paused = !Data.time_paused
	time_pause.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
	
func _build_building(id):
	Game.build_building.emit(Data.buildings[id])
