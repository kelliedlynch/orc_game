extends "res://maps/OrcGameMapTile.gd"
class_name WorldMapTile

var plateId: int

func _init(x: int, y: int).(x, y):
	pass

func _to_string():
	var string = "worldMapTile at " + str(x) + ", " + str(y) + "\n"
	return string
