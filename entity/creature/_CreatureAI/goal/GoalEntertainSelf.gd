extends GOAPGoal
class_name GoalEntertainSelf

# Things that must be true for this goal to be considered
func requirements(conditions: Dictionary = {}) -> Dictionary:
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			'idle_state': Creature.IdleState.IDLE
		}
	}
	return conditions

# The desired outcome of the goal
func end_state(transform: Dictionary = {}) -> Dictionary:
	transform = {
		'creature': {
			'idle_state': Creature.IdleState.PLAYING
		}
	}
	return transform

func get_priority() -> int:
	return Goal.PRIORITY_IDLE

func get_class(): return 'GoalEntertainSelf'
