extends Camera2D

const SPEED = 256

func _process(delta):
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += vector * SPEED * delta
