extends Node

signal province_selected(data)

func _ready():
	province_selected.connect(_province_selected)

func _province_selected(data):
	print(data)
