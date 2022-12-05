extends Node

var pathfinder = Pathfinder.new()

var game_speed: int = GameSpeed.NORMAL

enum GameSpeed {
	PAUSED,
	NORMAL,
}

var tile_size: Vector2 = Vector2(16, 16)
