extends OGCreature
class_name OGSentientCreature

var goals: Array = []
var actions: Array = []

var current_goal: GOAPGoal
var current_plan: Array
var current_plan_step: int

# interval is time in seconds between AI ticks, elapsed is how long since last tick
# This is how fast the creature 'thinks', lower is faster
var interval: float = 0.1
var elapsed: float = 0.0


func _init():
	pause_mode = PAUSE_MODE_STOP

func move_toward_location(loc: Vector2):
	var path = Global.pathfinder.get_path(location, loc)
	if path.empty(): return
	self.location = path[0]
	
func _process(delta):
	elapsed += delta
	if elapsed > interval:
		_run_agent()
		elapsed = 0

func _run_agent():
	pass
	
func get_class(): return 'OGSentientCreature'
