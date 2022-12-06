extends EntityModel
class_name CreatureModel

var type: int
var subtype: int
var first_name: String

var current_state = CreatureState.IDLE
var current_job = null

var inventory = []

# interval is time in seconds between AI ticks, elapsed is how long since last tick
# This is how fast the creature 'thinks', lower is faster
var interval: float = 0.1
var elapsed: float = 0.0
# The higher the laziness, the longer the creature will remain idle between actions
# This is how fast the creature works
var laziness: float = 0.1
var time_idle: float = 0.0
# higher move_delay means the creature will take longer between move steps
var move_delay: float = 0.1
# higher move_power means the creature can traverse more difficult terrain
# this affects climbing ability, speed over ground obstacles, fall damage
var move_power: float = 0.1

var current_path = [] setget set_current_path

func set_current_path(val: Array):
	current_path = val
	if val.size() > 0:
		current_state = CreatureState.MOVING
#		connect("reached_end_of_path", self, '_on_reached_end_of_path')
	else:
		emit_signal('reached_end_of_path')
		
signal reached_end_of_path()

enum CreatureState {
	IDLE,
	MOVING,
	WORKING,
}

enum CreatureSkill {
	HAULING,
	FARMING,
	FIGHTING,
}

func _init():
	pause_mode = PAUSE_MODE_STOP

func _ready():
	add_to_group('creatures')
	JobDispatch.connect("worker_requested", self, "_on_worker_requested")
	if connect('job_accepted', JobDispatch, '_on_job_accepted'):
		push_error('job_accepted connection failed in Creature')
		
func generate_first_name() -> String:
	var method2_chance = max(first_name_syllable1.size() - 1, first_name_syllable2.size() - 1)
	var method3_chance = max(first_name_word1.size() - 1, first_name_word2.size() -1)
	var methods = first_name_complete.size() - 1 + method2_chance + method3_chance
	var method = randi() % methods
	var _first: Array
	var _second: Array
	if method < first_name_complete.size():
		return first_name_complete[method]
	elif method >= method2_chance and method < method3_chance:
		_first = first_name_syllable1
		_second = first_name_syllable2
	else:
		_first = first_name_word1
		_second = first_name_word2
	return _first[randi() % (_first.size() - 1)] + _second[randi() % (_second.size() - 1)]
	
func _process(delta):
	elapsed += delta
	if elapsed < interval:
		return
	elapsed = 0.0
	if current_state == CreatureState.MOVING:
		_step_along_path()
	if current_state == CreatureState.IDLE:
		if time_idle / 4  + (randf() - .5) / 4 > laziness:
			choose_next_behavior()
			time_idle = 0.0
		else:
			time_idle += delta
		
func choose_next_behavior():
	for priority_level in behavior_priority:
		for behavior in priority_level:
			if self.call(behavior):
				break

func _step_along_path():
	var loc = current_path.pop_back()
	if current_path.size() == 0:
		emit_signal("reached_end_of_path")
	else:
		self.location = loc
		
func _on_reached_end_of_path():
#	current_state = CreatureState.IDLE
	pass

func _wander() -> bool:
	var tiles = get_parent().tiles_adjacent_to_creature(self)
	var tile = tiles[randi() % (tiles.size())]
	self.location = Vector2(tile.x, tile.y)
	return true

#func find_path_to_tile(to_x: int, to_y: int):
#	current_state = CreatureState.MOVING
#	var position_id = Global.pathfinder.xy_to_index(location.x, location.y)
#	var destination_id = Global.pathfinder.xy_to_index(to_x, to_y)
#	current_path = Global.pathfinder.get_id_path(position_id, destination_id)
#	current_path.remove(0)

func _on_worker_requested(job):
	if !job.worker:
		print('job accepted!')
		accept_job(job)
	
func accept_job(job):
	current_state = CreatureState.WORKING
	job.connect('job_completed', self, '_on_job_completed')
	emit_signal('job_accepted', job, self)
	
func _on_job_completed(job):
	current_state = CreatureState.IDLE
	if current_job == job:
		current_job.queue_free()
		current_job = null


signal job_accepted(job, worker)

# Name generator variables to be set by creature type/subtype
var first_name_complete: Array
var first_name_syllable1: Array
var first_name_syllable2: Array
var first_name_word1: Array
var first_name_word2: Array

enum Priority {
	EMERGENCY,
	HIGH,
	MEDIUM,
	LOW,
	IDLE,
}
var behavior_priority: Array = [
	# EMERGENCY
	[
		
	],
	# HIGH
	[
		
	],
	# MEDIUM
	[
		
	],
	# LOW
	[
		
	],
	# IDLE
	[
		'_wander'
	],
]

