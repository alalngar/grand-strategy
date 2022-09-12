extends CanvasLayer
@onready var province_panel := $ProvincePanel
@onready var province_name := $ProvincePanel/VBoxContainer/ProvinceName
@onready var province_population := $ProvincePanel/VBoxContainer/Population
@onready var date := $Panel/Panel/Date
@onready var treasury := $Panel/HBoxContainer/Money
@onready var button_increase_speed = $Panel/Panel/HBoxContainer/IncreaseSpeed
@onready var button_decrease_speed = $Panel/Panel/HBoxContainer/DecreaseSpeed
@onready var game_speed_visual = $Panel/Panel/GameSpeed

func _ready():
	Game.selected_province.connect(_selected_province)
	button_increase_speed.pressed.connect(_game_speed_change.bind(-1))
	button_decrease_speed.pressed.connect(_game_speed_change.bind(1))
	game_speed_visual.text = str(Data.game_speed_multiplier)

func _process(delta):
	date.text = Data.get_date_extended() #str(ceil(Game.country.treasury))
	treasury.text = "Treasury: " + str(ceil(Game.country.treasury))
	
func _selected_province(data):
	if data == null:
		province_panel.visible = false
		return
	province_panel.visible = true
	province_name.text = tr("p" + str(data.id))
	province_population.text = "Population: " + str(data.population)
	if data.population == -1:
		province_population.text = "Who tf Lives Here"

func _game_speed_change(num):
	if num == 1:
		if Data.game_speed_multiplier < 1:
			Data.game_speed_multiplier += 0.2
			game_speed_visual.text = str(Data.game_speed_multiplier)
	elif num == -1:
		if Data.game_speed_multiplier > 0.3:
			Data.game_speed_multiplier -= 0.2
			game_speed_visual.text = str(Data.game_speed_multiplier)
