extends GOAPAction

var item: OGItem


func requirements(conditions: Array = []) -> Array:
	var all_conditions = conditions.append_array([
		{ 'creature.has_arms': true },
	])
	return .requirements(all_conditions)

func trigger_conditions(conditions: Array = []) -> Array:
	var all_conditions = conditions.append_array(
		[AND, 
			[OR, 
				{ 'item.is_in_group': Group.Item.UNTAGGED_ITEMS },
				{ 'creature.tagged': [ HAS, item ] },
			],
			[OR,
				{ 'item.is_in_group': Group.Item.UNOWNED_ITEMS },
				{ 'creature.owned': [ HAS, item ] },
			],
		]
	)
	return .trigger_conditions(all_conditions)
	
func get_results(results: Array) -> Array:
	var properties_array = [HAS]
	for property in item.get_property_list():
		properties_array.append({ property: item.get(property) })
	
	var all_results = results.append_array([
		{ 'creature.inventory': properties_array }
	])
	return .get_results(all_results)
	
func get_cost(_blackboard) -> int:
	return 0
