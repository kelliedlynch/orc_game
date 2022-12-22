extends GOAPQueryable
class_name GOAPGoal

var creature: OGCreature


# Things that must be true for this goal to be considered
# These are things that can't be affected by the creature during execution of the goal
# OR
# things that might change during execution, but should not stop execution when they do
#func requirements(conditions: Dictionary = {}) -> Dictionary:
#	conditions.append_array([])
#	return conditions

# The conditions that activate the goal
#func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
#	conditions.append_array([])
#	return conditions

# The desired outcome of the goal
#func desired_state(query: Dictionary = {}) -> Dictionary:
#	query.append_array([])
#	return query

func get_priority() -> int:
	return Goal.PRIORITY_IDLE

func get_class(): return 'GOAPGoal'

