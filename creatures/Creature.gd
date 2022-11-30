extends Area2D

# Interval is time in seconds between AI ticks, elapsed is how long since last tick
var interval: float = 0.1
var elapsed: float = 0.0
# The higher the laziness, the longer the creature will remain idle
var laziness: float = 0.1
var time_idle: float = 0.0

var tile_size = 16
var map_position = { 'x': 0, 'y': 0 }
var current_state = CreatureState.IDLE

enum CreatureState {
	IDLE,
	WORKING,
}

func _init(x: int = 31, y: int = 18):
	map_position.x = x
	map_position.y = y
	position = Vector2(x, y) * tile_size
	position += Vector2.ONE * tile_size/2
	prints('position', position, map_position.x, map_position.y)

func _process(delta):
	elapsed += delta
	if elapsed < interval:
		return
	elapsed = 0.0
	if current_state == CreatureState.IDLE:
		wander(delta)
		
func wander(delta):
	time_idle += delta
	if time_idle / 4  + randf() / 5 > laziness:
		print('moving')
		var dx = sign(rand_range(-1, 1))
		var dy = sign(rand_range(-1, 1))
		
		position += Vector2(dx, dy) * tile_size
		time_idle = 0.0
	
		
