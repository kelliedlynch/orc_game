extends GOAPGoal
class_name GoalEntertainSelf

func is_valid() -> bool:
	return true
	
func get_priority() -> int:
	return Goal.PRIORITY_IDLE
	
func trigger_conditions() -> Dictionary:
	return {
		'is_entertained': false
	}
	
func get_desired_outcome() -> Dictionary:
	return {
		'is_entertained': true
	}

func assign_to_creature(creature: OGCreature):
	.assign_to_creature(creature)
	creature.state_tracker.set_state_for('is_entertained', false)

func _set_is_entertained():
	# This goal will never actually entertain the creature, as it's the fallback if
	# everything else fails
	pass

func get_class(): return 'GoalEntertainSelf'
