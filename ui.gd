extends CanvasLayer

@onready var province_panel := $Control/ProvincePanel
@onready var province_name := $Control/ProvincePanel/VBoxContainer/ProvinceName
@onready var province_population := $Control/ProvincePanel/VBoxContainer/Population
@onready var date := $Control/TimePanel/Date
@onready var treasury := $Control/InfoPanel/MarginContainer/HBoxContainer/Money
@onready var button_increase_speed = $Control/TimePanel/HBoxContainer/IncreaseSpeed
@onready var button_decrease_speed = $Control/TimePanel/HBoxContainer/DecreaseSpeed
@onready var button_pause_timer = $Control/TimePanel/HBoxContainer/PauseTimer
#@onready var game_speed = $Control/TimePanel/HBoxContainer/GameSpeed

func _ready():
	Game.selected_province.connect(_selected_province)
	button_increase_speed.pressed.connect(_increase_speed)
	button_decrease_speed.pressed.connect(_decrease_speed)
	button_pause_timer.pressed.connect(_pause_timer)

func _process(delta):
	date.text = Data.get_date_extended()
	treasury.text = "Treasury: " + str(ceil(Game.country.treasury))
	
func _selected_province(data):
	if data == null:
		province_panel.visible = false
		return
	
	province_panel.visible = true
	province_name.text = tr("p" + str(data.id))
	province_population.text = "Population: " + str(data.population)

func _pause_timer():
	Data.time_paused = !Data.time_paused
	button_pause_timer.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)
	#game_speed.text = str(Data.time_speed)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
	#game_speed.text = str(Data.time_speed)
