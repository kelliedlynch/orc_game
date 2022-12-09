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

func _init():
	#initialize random number generator
	randomize()

func _ready():
	pathfinder = Pathfinder.new()
