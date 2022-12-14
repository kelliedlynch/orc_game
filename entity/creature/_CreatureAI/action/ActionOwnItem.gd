extends GOAPAction

var item: OGItem

func requirements(conditions: Array = []) -> Array:
	var all_conditions = conditions.append_array([])
	return .requirements(all_conditions)

func trigger_conditions(conditions: Array = []) -> Array:
	var all_conditions = conditions.append_array([
			{ 'item.is_in_group': Group.Item.UNOWNED_ITEMS },
		]
	)
	return .trigger_conditions(all_conditions)
	
func end_state(results: Array) -> Array:
	var all_results = results.append_array([
		{ 'creature.inventory': [ HAS, item ] }
	])
	return .get_results(all_results)
	
func get_cost(_blackboard) -> int:
	return 0
