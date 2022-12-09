extends GOAPGoal
class_name GoalEntertainSelf

func _set_state_tracker(val):
	state_tracker = val
	state_tracker.set_state_for('is_entertained', false)

func is_valid() -> bool:
	return true
	
func get_priority() -> int:
	return 0
	
func trigger_conditions() -> Dictionary:
	return {
		'is_entertained': false
	}
	
func get_desired_outcome() -> Dictionary:
	return {
		'is_entertained': true
	}

func _set_is_entertained():
	# This goal will never actually entertain the creature, as it's the fallback if
	# everything else fails
	pass
