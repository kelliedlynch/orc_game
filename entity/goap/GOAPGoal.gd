extends Node
class_name GOAPGoal

#Currently the StateTracker is responsible for setting signals, but I think Goals should do that.
#StateTracker should be a totally generic class, I think. A creature's GOAP signals will be
#determined by the goals it has set.
var actor: OGCreature setget _set_actor
var state_tracker: GOAPStateTracker setget _set_state_tracker

func _set_actor(val):
	actor = val
	
func _set_state_tracker(val):
	state_tracker = val

func is_valid() -> bool:
	return true

func get_priority() -> int:
	return 0
	
func get_desired_outcome() -> Dictionary:
	return {}
