extends CanvasLayer

func _process(delta):
	$Label.text = str(ceil(Game.country.treasury))
