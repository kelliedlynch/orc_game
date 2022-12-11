extends OrcGameMapController
class_name RegionMapController

#onready var inspector: TabContainer = $Inspector

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _ready():
	map = $RegionMap
	WorldData.set_current_map(map)

func toggle_game_speed():
	if Global.game_speed == Global.GameSpeed.PAUSED:
		Global.game_speed = Global.GameSpeed.NORMAL
		get_tree().paused = false
	else:
		Global.game_speed = Global.GameSpeed.PAUSED
		get_tree().paused = true
		
func _get_target_at_location(loc: Vector2) -> Object:
	var tile = map.tile_at(loc)
	var target
	var c = tile.get_creatures()
	var i = tile.get_items()
	if c.size() > 0:
		target = c.back()
	elif i.size() > 0:
		target = i.back()
	elif tile:
		target = tile
	return target

func _input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_SPACE:
					if event.is_pressed(): toggle_game_speed()

#func _unhandled_input(event):
#	match event.get_class():
#		'InputEventMouseButton':
#			if event.is_pressed():
#				if event.button_index == BUTTON_LEFT:
#					Global.set_player_target(_get_target_at_location(SpriteManager.position_to_location(event.position)))
