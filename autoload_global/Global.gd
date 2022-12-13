extends Node

var pathfinder

# the default size in tiles of maps (will probably have to be handled differently later)
var map_size = Vector2(200, 100)
# the default size of game sprites
var tile_size = Vector2(16, 16)


var game_speed: int = GameSpeed.NORMAL

enum GameSpeed {
	PAUSED,
	NORMAL,
}

enum RenderLayer {
	MAP_LAYER,
	SPRITE_LAYER,
	GUI_LAYER,
}

var OFF_MAP = Vector2(-1, -1)

var _player_target: Object = null setget set_player_target, get_player_target

func set_player_target(obj: Object):
	var prev = _player_target
	_player_target = obj
	emit_signal("player_target_changed", _player_target, prev)
signal player_target_changed()

func get_player_target():
	return _player_target

func _init():
	#initialize random number generator
	randomize()

func _ready():
	pathfinder = Pathfinder.new()
	
