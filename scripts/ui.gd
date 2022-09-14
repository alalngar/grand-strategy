extends CanvasLayer

@onready var bb_scene := preload("res://building_button.tscn")

@onready var prov_panel := $UI/ProvPanel
@onready var prov_close = $UI/ProvPanel/Close
@onready var prov_name := $UI/ProvPanel/VB/ProvName
@onready var prov_pop := $UI/ProvPanel/VB/PopValue
@onready var prov_build_open := $UI/ProvPanel/Buildings
@onready var prov_build_panel := $UI/ProvPanel/BuildPanel
@onready var prov_build_cont := $UI/ProvPanel/BuildPanel/SC/VB

@onready var info_treasury := $UI/InfoPanel/MC/HB/VB1/HB/Gold
@onready var info_income := $UI/InfoPanel/MC/HB/VB1/Income
@onready var info_total_pop := $UI/InfoPanel/MC/HB/VB2/HB/Pop
@onready var info_monthly_pop := $UI/InfoPanel/MC/HB/VB2/Growth
@onready var info_flag := $UI/InfoPanel/MC/HB/Flag

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
	prov_close.pressed.connect(_deselect_province)
	prov_build_open.pressed.connect(_open_buildings_panel)
	
	for id in Data.buildings:
		var building = Data.buildings[id]
		if building == null: continue
		var scene := bb_scene.instantiate()
		scene.get_child(1).text = "x%d " % building.cost
		scene.get_child(2).text = tr("b%d" % building.id)
		scene.pressed.connect(_build_building.bind(building.id))
		prov_build_cont.add_child(scene)

func _process(delta):
	time_date.text = Data.get_date_extended()
	
	info_treasury.text = str(ceil(Game.country.treasury))
	#info_income.text = "+%.2f Gold" % Game.last_monthly_income if Game.last_monthly_income >= 0.0 else "-%.2f Gold" % Game.last_monthly_income
	#info_total_pop.text = str(ceil(Game.total_population))
	#info_monthly_pop.text = "(+%.0f)" % Game.monthly_population
	info_flag.texture = Game.country.flag
	
	_update_province_panel()

func _selected_province(data):
	prov_panel.visible = false if data == null else true

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

func _open_buildings_panel():
	prov_build_open.text = "+" if prov_build_panel.visible else "-" 
	prov_build_panel.visible = !prov_build_panel.visible
