extends GOAPQueryable
class_name GOAPGoal

var creature: OGCreature

# NOTE: there is no real difference between requirements and trigger conditions, they're just
# a way to split things up a bit conceptually. In general, requirements are things that disqualify
# the goal from consideration, while trigger conditions are things that qualify

# Things that must be true for this goal to be considered
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

func assign_to_creature(creature_: OGCreature):
	creature = creature_

func unassign():
	creature = null

func is_valid() -> bool:
	return true

func get_priority() -> int:
	return Goal.PRIORITY_IDLE
	

	
func get_desired_outcome() -> Dictionary:
	return {}

func get_class(): return 'GOAPGoal'

