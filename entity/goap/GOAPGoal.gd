extends Node
class_name GOAPGoal

#Currently the StateTracker is responsible for setting signals, but I think Goals should do that.
#StateTracker should be a totally generic class, I think. A creature's GOAP signals will be
#determined by the goals it has set.

func is_valid() -> bool:
	return true

func get_priority() -> int:
	return 0
	
func get_desired_outcome() -> Dictionary:
	return {}
