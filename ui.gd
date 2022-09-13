extends CanvasLayer

@onready var province_panel := $Control/ProvincePanel
@onready var province_name := $Control/ProvincePanel/VBoxContainer/ProvinceName
@onready var province_population := $Control/ProvincePanel/VBoxContainer/Population
@onready var date := $Control/TimePanel/Date
@onready var treasury := $Control/InfoPanel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Money
@onready var income := $Control/InfoPanel/MarginContainer/HBoxContainer/VBoxContainer/Income
@onready var country := $Control/InfoPanel/MarginContainer/HBoxContainer/CountryName
@onready var button_increase_speed = $Control/TimePanel/HBoxContainer/IncreaseSpeed
@onready var button_decrease_speed = $Control/TimePanel/HBoxContainer/DecreaseSpeed
@onready var button_pause_timer = $Control/TimePanel/HBoxContainer/PauseTimer

var selected_province

func _ready():
	Game.selected_province.connect(_selected_province)
	Data.daily_tick.connect(_update_province_panel)
	button_increase_speed.pressed.connect(_increase_speed)
	button_decrease_speed.pressed.connect(_decrease_speed)
	button_pause_timer.pressed.connect(_pause_timer)

func _process(delta):
	date.text = Data.get_date_extended()
	treasury.text = str(ceil(Game.country.treasury))
	country.text = Game.country.tag
	income.text = "+%.2f Gold" % Game.last_monthly_income if Game.last_monthly_income >= 0.0 else "-%.2f Gold" % Game.last_monthly_income
	
	_update_province_panel()

func _selected_province(data):
	selected_province = data
	province_panel.visible = false if data == null else true

func _update_province_panel():
	if selected_province:
		province_name.text = tr("p" + str(selected_province.id))
		province_population.text = "Population: %.0f" % selected_province.population

func _pause_timer():
	Data.time_paused = !Data.time_paused
	button_pause_timer.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
