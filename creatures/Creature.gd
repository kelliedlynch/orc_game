extends Area2D
class_name Creature

# Interval is time in seconds between AI ticks, elapsed is how long since last tick
var interval: float = 0.1
var elapsed: float = 0.0
# The higher the laziness, the longer the creature will remain idle
var laziness: float = 0.1
var time_idle: float = 0.0

var tile_size = 16
var map_position = { 'x': 0, 'y': 0 }
var current_state = CreatureState.IDLE
var current_path = []
var current_job = null

enum CreatureState {
	IDLE,
	WORKING,
}

func _init(x: int = 31, y: int = 18):
	map_position.x = x
	map_position.y = y
	set_map_position(x, y)
	JobDispatch.connect("worker_requested", self, "_on_worker_requested")
	if connect('job_accepted', JobDispatch, '_on_job_accepted'):
		push_error('job_accepted connection failed in Creature')

func _process(delta):
	elapsed += delta
	if elapsed < interval:
		return
	elapsed = 0.0
	if current_path.size() > 0:
		var next_step = current_path[0]
		var coords = Global.pathfinder.index_to_xy(next_step)
		set_map_position(coords.x, coords.y)
		current_path.remove(0)
		if current_path.size() == 0:
			emit_signal('move_completed')
		return
	if current_state == CreatureState.IDLE:
		wander(delta)
		
func set_map_position(x, y):
	prints('set map position', x, y)
	map_position.x = x
	map_position.y = y
	position = Vector2(x, y) * tile_size
	position += Vector2.ONE * tile_size/2
		
func wander(delta):
	time_idle += delta
	if time_idle / 4  + randf() / 5 > laziness:
		var dx = sign(rand_range(-1, 1))
		var dy = sign(rand_range(-1, 1))
		map_position.x += dx
		map_position.y += dy
		position += Vector2(dx, dy) * tile_size
		time_idle = 0.0
		
func go_to_tile(x: int, y: int):
	prints('go to tile ', x, y)
	var position_id = Global.pathfinder.xy_to_index(map_position.x, map_position.y)
	var destination_id = Global.pathfinder.xy_to_index(x, y)
	current_path = Global.pathfinder.get_id_path(position_id, destination_id)
	prints('current path is', current_path)
	current_path.remove(0)
	
func _on_worker_requested(job):
	prints('_on_worker_requested', job)
	accept_job(job)
	
func accept_job(job):
	current_state = CreatureState.WORKING
	job.connect('job_completed', self, '_on_job_completed')
	emit_signal('job_accepted', job, self)

func _on_job_completed(job):
	current_state = CreatureState.IDLE
	if current_job == job:
		current_job = null

signal job_accepted(job, worker)
signal move_completed()
