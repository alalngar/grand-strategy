extends CanvasLayer

func _ready():
	Game.selected_province.connect(_selected_province)

func _selected_province(data):
	$Label.text = tr(str(data.id))
