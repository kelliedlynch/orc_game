extends OrcGameMapController
class_name RegionMapController

#onready var inspector: TabContainer = $Inspector

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _ready():
	map = $RegionMap

func _input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_SPACE:
					if event.is_pressed(): toggle_game_speed()

func toggle_game_speed():
	if Global.game_speed == Global.GameSpeed.PAUSED:
		Global.game_speed = Global.GameSpeed.NORMAL
		get_tree().paused = false
	else:
		Global.game_speed = Global.GameSpeed.PAUSED
		get_tree().paused = true
