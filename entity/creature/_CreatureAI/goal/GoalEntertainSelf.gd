extends GOAPGoal
class_name GoalEntertainSelf

# Things that must be true for this goal to be considered
func requirements(conditions: Array = []) -> Array:
	conditions.append_array([])
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Array = []) -> Array:
	conditions.append_array([
		{ 'creature.idle_state': Creature.IdleState.IDLE }
	])
	return conditions

# The desired outcome of the goal
func end_state(conditions: Array = []) -> Array:
	conditions.append_array([
		{ 'creature.idle_state': Creature.IdleState.PLAYING }
	])
	return conditions

func get_priority() -> int:
	return Goal.PRIORITY_IDLE

func get_class(): return 'GoalEntertainSelf'
