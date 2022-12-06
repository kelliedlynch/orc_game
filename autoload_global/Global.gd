extends Node

var pathfinder = Pathfinder.new()

var game_speed: int = GameSpeed.NORMAL

enum GameSpeed {
	PAUSED,
	NORMAL,
}

var tile_size: Vector2 = Vector2(16, 16)

func position_to_location(pos: Vector2):
	var x = floor(pos.x / tile_size.x)
	var y = floor(pos.y / tile_size.y)
	return Vector2(x, y)

func location_to_position(loc: Vector2):
	return loc * tile_size
