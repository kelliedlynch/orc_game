extends Node
class_name GOAPQueryable

# Base class for Actions and Goals, implements query language for conditions and results

enum {
	AND,
	OR,
	NOT,
	HAS,
	# HAS syntax: [ HAS, { property_name: String = property_value: Variant, ..., (optional) QUANTITY = qty: int } ]
	GREATER_THAN,
	GREATER_OR_EQUAL,
	LESS_THAN,
	LESS_OR_EQUAL,
	EQUAL,
	NOT_EQUAL,
	QUANTITY,
}

# Evaluates an array of state conditions to see whether it matches the world state
# 'QUERY_TYPE' is 'AND', 'OR', etc.
# 'condition' means { 'description': value }
# 'compound condition' means [ QUERY_TYPE, condition or compound condition, ... ]
# 'simulated_state' is an additional query array to check for conditions, used in path planning


func evaluate_query(query: Array, for_creature: OGCreature, simulated_state: Array = []) -> bool:

# GOAL STATE:		
#	[
#		AND,
#			{ 'creature.owned': [ HAS, { 'material': 'bone' } ] },
#			{ 'creature.inventory': [ HAS, { 'material': 'bone' } ] },
#	]

# ACTION OUTCOME
#	[
#		{ 'creature.inventory': properties_array }
#	]
	
	
	var query_first = query.front()
	match typeof(query_first):
		TYPE_INT:
			# the query type is the given query type, and evaluation starts with the first condition (next item in array)
			match query_first:
				AND:
					var and_conditions = query.slice(1, query.size() - 1)
					for condition in and_conditions:
						var conditions_match = evaluate_query(condition, for_creature, simulated_state)
						if conditions_match == false:
							return false
					return true
				OR:
					var or_conditions = query.slice(1, query.size() - 1)
					for condition in or_conditions:
						var conditions_match = evaluate_query(condition, for_creature, simulated_state)
						if conditions_match == true:
							return true
					return false
				NOT:
					var not_conditions = query.slice(1, query.size() - 1)
					for condition in not_conditions:
						var conditions_match = evaluate_query(condition, for_creature, simulated_state)
						if conditions_match == true:
							return false
					return true
				_:
					push_error('Invalid operator for outer query')
		TYPE_DICTIONARY:
			# the query type is AND, and evaluation starts with this condition
			var condition_matches = _evaluate_condition(query_first, for_creature, simulated_state)
			if !condition_matches:
				return false
			if query.size() > 1:
				var remaining_conditions_match = evaluate_query(query.slice(1, query.size() - 1), for_creature, simulated_state)
				if remaining_conditions_match:
					return true
			return true
		TYPE_ARRAY:
			# the query type is AND, and evaluation starts with this compound condition
			for condition in query:
				var conditions_match = evaluate_query(condition, for_creature, simulated_state)
				if conditions_match == false:
					return false
			return true
	return true
	
func _evaluate_inner_query(query: Array, for_creature: OGCreature, property: String, simulated_state: Array ) -> bool:
	match query.front():
		HAS:
			return _evaluate_has_query(query.back(), for_creature, property, simulated_state)
		_:
			return _evaluate_operator_query(query.front(), for_creature.get(property), query.back())
	return false
	
func _evaluate_operator_query(operator: int, left_val, right_val):
	match operator:
		GREATER_THAN:
			return left_val > right_val
		GREATER_OR_EQUAL:
			return left_val >= right_val
		LESS_THAN:
			return left_val < right_val
		LESS_OR_EQUAL:
			return left_val <= right_val
		NOT_EQUAL:
			return left_val != right_val
		EQUAL, _:
			return left_val == right_val
	
func _evaluate_has_query(seeking_props: Dictionary, for_creature: OGCreature, property: String, simulated_state: Array) -> bool:
	# This query checks an array property on an creature to see if it contains elements
	# with the given properties, and looks for missing elements in the simulated state
	# example seeking_props: { 'material': 'bone', 'value': [ GREATER_THAN: 10 ], QUANTITY: 3 }
	# example property: 'inventory'
	var prop_list = seeking_props.duplicate(true)
	print('creature ', for_creature)
	var creature_prop_list = for_creature.get(property)
	print('creature_prop_list ', creature_prop_list)
	if !prop_list.has(QUANTITY):
		prop_list[QUANTITY] = 1
	for item in creature_prop_list:
		var matched_all_props = true
		for prop in prop_list:
			if prop is int and prop == QUANTITY:
				continue
			if typeof(prop_list[prop]) == TYPE_ARRAY:
				# this is another query to evaluate
				pass
			print('prop ', prop, ' item ', item)	
			if prop in item:
				if item.get(prop) == prop_list[prop]:
					continue
			#this item is missing one of the props
			matched_all_props = false
		if matched_all_props:
			# TODO: CHANGE THIS TO WHATEVER SYNTAX I USE FOR TRACKING STACKING ITEMS
			if item.get('quantity'):
				prop_list[QUANTITY] -= item['quantity']
			else:
				prop_list[QUANTITY] -= 1
			if prop_list[QUANTITY] <= 0:
				if simulated_state.empty(): return true
	# now check the simulated state for matching props
	var sim_has = _find_has_conditions_in_simulated_state(simulated_state)
	var missing_props = _evaluate_query_condition_against_simulated_state(prop_list, sim_has)
	print('missing ', missing_props)
	if missing_props.empty():
		return true
	return false


#	query_dict =  { 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] }

#	simulated_state = [
#		[ target.OR,
#			{ 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] },
#			{ 'creature.inventory': [ target.HAS { 'material': 'wood'} ] },
#		],
#		{ 'creature.owned': [ target.HAS, {'material': 'wood'}]},
#		[ target.NOT,
#			[ target.OR,
#				[ target.AND,
#					{ 'creature.inventory': [ target.HAS,
#											{
#												'material': 'silk',
#												target.QUANTITY: 5,
#											},
#					]}
#				]
#			]
#		]
#	]

	
# returns a dictionary showing what's missing from the query
func _evaluate_query_condition_against_simulated_state(query_dict: Dictionary, sim_cond):
	var remaining = query_dict.duplicate(true)
	match typeof(sim_cond):
		TYPE_ARRAY:
			var operator = sim_cond.front()
			var simulated_conditions = sim_cond.slice(1, sim_cond.size() - 1)
			match operator:
				AND:
					for condition in simulated_conditions:
						remaining = _evaluate_query_condition_against_simulated_state(remaining, condition)
						if remaining.empty():
							return {}
					return remaining
				OR:
					for condition in simulated_conditions:
						remaining = _evaluate_query_condition_against_simulated_state(query_dict, condition)
						if remaining.empty():
							return {}
					# THIS WILL ONLY RETURN THE MOST RECENT ITERATION, RATHER THAN THE CLOSEST MATCH
					# DOES THAT MATTER?
					return remaining
				NOT:
					# NOT CONDITIONS ARE CONFUSING ME A LITTLE, BUT I THINK WE'RE ONLY GOING FOR A 
					# TRUE/FALSE IN THE END, SO WE ONLY CARE ABOUT EMPTY/NON-EMPTY RETURNS
					for condition in simulated_conditions:
						remaining = _evaluate_query_condition_against_simulated_state(query_dict, condition)
						if remaining.empty():
							return query_dict
					return {}
		TYPE_DICTIONARY:
			var query_found = _evaluate_query_condition_against_simulated_condition(query_dict, sim_cond)
			return query_found



# goal looks like: { 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] }
# returns a dictionary showing HAS state conditions that haven't been satisfied (or empty)
func _evaluate_query_condition_against_simulated_condition(goal_: Dictionary, sim: Dictionary) -> Dictionary:
	var goal = goal_.duplicate(true)
	# ARE THESE CHECKS NECESSARY? WE MIGHT BE DOING THEM BEFORE CALLING THIS FUNCTION
	for goal_key in goal.keys():
		if sim.has(goal_key):
			var goal_query = goal[goal_key]
			var s = sim[goal_key]
			if (goal_query is Array and goal_query.front() == HAS and s is Array and s.front() == HAS):
	# END OF MAYBE UNNECESSARY CHECKS
				var goal_seeking = goal_query.slice(1, goal_query.size() - 1)
#				var return_array = goal_seeking.duplicate(true)
				var sim_contains = s.slice(1, s.size() - 1)
				var index = 0
				for seeking in goal_seeking:
					
					var all_matching_dicts = []
					var qty_needed = 1
					if seeking.has(QUANTITY):
						qty_needed = seeking[QUANTITY]
						seeking.erase(QUANTITY)
					var seeking_keys = seeking.keys()
					# seeking should be a dictionary { 'material': 'bone' }
					# property is a key 'material'
					for contains in sim_contains:
						if contains.has_all(seeking_keys):
							all_matching_dicts.append(contains)
					for dict in all_matching_dicts:
						var all_properties_match = true
						for property in seeking_keys:
							if seeking.get(property) is Array and seeking.get(property)[0] is int:
								var valid = _evaluate_operator_query(seeking[property][0], dict.get(property), seeking[property][1])
								if !valid:
									all_properties_match = false
									break
						if all_properties_match:
							qty_needed -= dict[QUANTITY] if dict.has(QUANTITY) else 1
						if qty_needed <= 0:
							break
					if qty_needed <= 0:
						goal_seeking[index] = {}
					else:
						goal_seeking[index][QUANTITY] = qty_needed
					index +=1
				var g = []
				for item in goal_seeking:
					if !item.empty():
						g.append(item)
				if g.empty():
					goal.erase(goal_key)
	return goal
	


func _find_has_conditions_in_simulated_state(sim: Array):
	var sim_first = sim.front()
	var return_array = []
	match typeof(sim_first):
		TYPE_INT:
			match sim_first:
				AND, OR, NOT:
					return_array.append(sim_first)
					var has_conditions = []
					for condition in sim.slice(1, sim.size() - 1):
						match typeof(condition):
							TYPE_DICTIONARY:
								var found = _find_has_conditions_in_simulated_state([condition])
								if !found.empty():
									has_conditions.append_array(found)
							TYPE_ARRAY:
								var found = _find_has_conditions_in_simulated_state(condition)
								if !found.empty():
									has_conditions.append(found)
							_:
								continue
					if has_conditions.size() > 0:
						return_array.append_array(has_conditions)
		TYPE_DICTIONARY, TYPE_ARRAY:
			for array_element in sim:
				match typeof(array_element):
					TYPE_DICTIONARY:
						for key in array_element:
							if array_element[key] is Array:
								if array_element[key].front() == HAS:
									return_array.append(array_element)
								elif typeof(array_element[key].front()) == TYPE_INT:
									var found = _find_has_conditions_in_simulated_state(array_element[key])
									if !found.empty():
										return_array.append(found)
								else:
									push_error("Can't compare property values as arrays; use 'has' notation instead")
					TYPE_ARRAY:
						var found = _find_has_conditions_in_simulated_state(array_element)
						if !found.empty():
							return_array.append(found)
		_:
			push_error('Simulated state has invalid syntax')
	return return_array


# evaluates a dictionary of states against the world state
# all states must be true to return true
func _evaluate_condition(condition: Dictionary, for_creature: OGCreature, simulated_state: Array ) -> bool:
	# example conditions: { 'creature.inventory': [ HAS, { 'material': 'bone' } ] }
	# { 'creature.intelligence': [ MORE_THAN, 10 ] }
	# { 'creature.creature_state: CreatureState.IDLE }
	
	
	for cn in condition:
		var condition_name: String = cn
		
		if '.' in condition_name:
			var condition_elements = condition_name.split('.')
			
			if condition_elements.front() == 'creature' && condition_elements.size() == 2:
				# this is a check of a property, function, or creature's inventory
				condition_name = condition_elements.back()
				var condition_value = condition[condition_name]
				if typeof(condition_value) == TYPE_ARRAY:
					# the condition value is another query, such as a list of properties for
					# and inventory item, or an operator comparison
					var creature_value = for_creature.get(condition_name)
					var matches = _evaluate_inner_query(condition_value.back(), for_creature, condition_name, simulated_state)
#					var matches = _evaluate_query_condition_against_simulated_condition(condition, simulated_state)
					if !matches: return false
					continue
				elif for_creature.has_method(condition_name):
					# it's a function
					if for_creature.call(condition_name) == condition_value:
						return true
					return false
				elif condition_name in for_creature:
					# it's a property
					if for_creature.get(condition_name) == condition_value:
							return true
					return false
			# WHAT OTHER THINGS COULD CONDITIONS BEGIN WITH?
	return true

func simulate_creature(creature: OGCreature) -> Dictionary:
	var simulated_creature = {}
	for property in creature.get_property_list():
		simulated_creature[property] = creature.get(property)
	return simulated_creature

func get_class(): return 'GOAPQueryable'
