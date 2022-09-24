extends Camera2D

var mouse_relative := Vector2.ZERO
var move_camera := false

const SPEED := 256

func _process(delta):
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += vector * SPEED * delta
	
	if Input.is_action_just_released("zoom_in"):
		zoom += Vector2.ONE
	elif Input.is_action_just_released("zoom_out"):
		zoom -= Vector2.ONE
	
	zoom = clamp(zoom, Vector2(1.0, 1.0), Vector2(5.0, 5.0))
	
	if move_camera:
		position += mouse_relative / -zoom
		mouse_relative = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_relative = event.relative
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		move_camera = true if event.pressed else false
