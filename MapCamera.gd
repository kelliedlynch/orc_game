extends Camera2D

var target: OrcGameMap

func _process(delta):
	position = target.position
