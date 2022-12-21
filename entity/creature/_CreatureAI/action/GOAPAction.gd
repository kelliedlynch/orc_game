extends GOAPQueryable
class_name GOAPAction

var creature: OGCreature


func is_valid(state) -> bool:
	return true


# NOTE: there is no real difference between requirements and trigger conditions, they're just
# a way to split things up a bit conceptually. In general, requirements are things that disqualify
# the action from consideration, while trigger conditions are things that qualify

# Things that must be true for this Action to be considered
#func requirements(conditions: Array = []) -> Array:
#	conditions.append_array([])
#	return conditions

# The conditions that activate the Action
#func trigger_conditions(conditions: Array = []) -> Array:
#	conditions.append_array([])
#	return conditions

# The outcome of the Action
# NOTE: This can lie. See ActionWander for example.
#func applied_transform(conditions: Array = []) -> Array:
#	conditions.append_array([])
#	return conditions
	
func get_cost() -> int:
	return 0

