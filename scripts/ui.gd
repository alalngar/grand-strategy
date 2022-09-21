extends CanvasLayer

@onready var income_lbl := $UI/TopPanel/HB2/Income

@onready var decrease_speed_btn := $UI/TopPanel/Time/HB/Decrease
@onready var increase_speed_btn := $UI/TopPanel/Time/HB/Increase
@onready var pause_time_btn := $UI/TopPanel/Time/HB/Pause
@onready var date_lbl := $UI/TopPanel/Time/Date

func _ready():
	_update_info()
	Data.daily_tick.connect(_daily_tick)
	
	pause_time_btn.pressed.connect(_pause_timer)
	increase_speed_btn.pressed.connect(_increase_speed)
	decrease_speed_btn.pressed.connect(_decrease_speed)

func _process(delta):
	date_lbl.text = Data.get_date()

func _daily_tick():
	_update_info()

func _update_info():
	income_lbl.text = "%.0f$" % Game.country.treasury

func _pause_timer():
	# todo sync time pausing for other players
	Data.time_paused = !Data.time_paused
	pause_time_btn.text = "=" if Data.time_paused else ">"

func _increase_speed():
	Data.time_speed = clamp(Data.time_speed - 0.2, 0.0, 1.0)

func _decrease_speed():
	Data.time_speed = clamp(Data.time_speed + 0.2, 0.0, 1.0)
