extends GOAPAction

var item: OGItem


func requirements(conditions: Array = []) -> Array:
	var all_conditions = conditions.duplicate()
	all_conditions.append_array([
		{ 'creature.has_arms': true },
	])
	return .requirements(all_conditions)

func trigger_conditions(conditions: Array = []) -> Array:
	var all_conditions = conditions.duplicate()
	all_conditions.append_array([

	])
	return .trigger_conditions(all_conditions)
	
func get_results(results: Array) -> Array:
	var all_results = results.duplicate()
	all_results.append_array([])

	return .get_results(all_results)
	
func get_cost(_blackboard) -> int:
	return 0
