extends CanvasLayer

@onready var province_panel := $Control/ProvincePanel
@onready var province_name := $Control/ProvincePanel/VBoxContainer/ProvinceName
@onready var province_population := $Control/ProvincePanel/VBoxContainer/Population
@onready var date := $Control/TimePanel/Date
@onready var treasury := $Control/InfoPanel/MarginContainer/TopBarUI/VBoxContainer2/HBoxContainer/Money
@onready var income := $Control/InfoPanel/MarginContainer/TopBarUI/VBoxContainer2/Income
@onready var total_population := $Control/InfoPanel/MarginContainer/TopBarUI/VBoxContainer/HBoxContainer/Population
@onready var monthly_population := $Control/InfoPanel/MarginContainer/TopBarUI/VBoxContainer/PopulationGrowth
@onready var country := $Control/InfoPanel/MarginContainer/TopBarUI/CountryName
@onready var button_increase_speed = $Control/TimePanel/HBoxContainer/IncreaseSpeed
@onready var button_decrease_speed = $Control/TimePanel/HBoxContainer/DecreaseSpeed
@onready var button_pause_timer = $Control/TimePanel/HBoxContainer/PauseTimer
@onready var button_close_province = $Control/ProvincePanel/Button

@onready var button_building1 = $Control/ProvincePanel/VBoxContainer/HBoxContainer/VBoxContainer/Building1
@onready var button_building2 = $Control/ProvincePanel/VBoxContainer/HBoxContainer/VBoxContainer/Building2
@onready var button_building3 = $Control/ProvincePanel/VBoxContainer/HBoxContainer/VBoxContainer/Building3

func _ready():
	Game.province_selected.connect(_selected_province)
	Data.daily_tick.connect(_update_province_panel)
	button_increase_speed.pressed.connect(_increase_speed)
	button_decrease_speed.pressed.connect(_decrease_speed)
	button_pause_timer.pressed.connect(_pause_timer)
	button_close_province.pressed.connect(_deselect_province)
	button_building1.pressed.connect(_build_building.bind(0))
	button_building2.pressed.connect(_build_building.bind(1))
	button_building3.pressed.connect(_build_building.bind(2))

func _process(delta):
	date.text = Data.get_date_extended()
	treasury.text = str(ceil(Game.country.treasury))
	country.text = Game.country.tag
	income.text = "+%.2f Gold" % Game.last_monthly_income if Game.last_monthly_income >= 0.0 else "-%.2f Gold" % Game.last_monthly_income
	total_population.text = str(ceil(Game.total_population))
	monthly_population.text = "(+%.0f)" % Game.monthly_population
	
	
	_update_province_panel()

func _selected_province(data):
	province_panel.visible = false if data == null else true

func _deselect_province():
	Game.province_selected.emit(null)	

func _update_province_panel():
	if Game.selected_province:
		province_name.text = tr("p" + str(Game.selected_province.id))
		province_population.text = "Population: %.0f" % Game.selected_province.population

func _pause_timer():
	Data.time_paused = !Data.time_paused
	button_pause_timer.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)

func _build_building(id):
	var building = Data.buildings[id]
	Game.build_buildings.emit(building)
