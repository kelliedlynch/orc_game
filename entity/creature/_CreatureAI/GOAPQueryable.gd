extends Node
class_name GOAPQueryable

# Base class for Actions and Goals, implements query language for conditions and results

enum {
	# Outer queries; can be used at any level
	AND,
	OR,
	NOT,
	
	# Inner queries; used when querying an array property
	# HAS syntax: [ HAS, { property_name: String = property_value: Variant, ..., (optional) QUANTITY = qty: int } ]
	HAS,
	# ADD and SUBTRACT are only used to describe changes to simulated states
	ADD,
	SUBTRACT,
	# QUANTITY can be used with any inner query
	QUANTITY,
	
	# Operator queries; used for comparing a property value
	GREATER_THAN,
	GREATER_OR_EQUAL,
	LESS_THAN,
	LESS_OR_EQUAL,
	EQUAL,
	NOT_EQUAL,
}

# Evaluates an array of state conditions to see whether it matches the world state
# 'QUERY_TYPE' is 'AND', 'OR', etc.
# 'condition' means { 'description': value }
# 'compound condition' means [ QUERY_TYPE, condition or compound condition, ... ]
# 'simulated_state' is an additional query array to check for conditions, used in path planning
func evaluate_query(query: Array, for_creature: OGCreature, simulated_state: Array = []) -> bool:
	var query_first = query.front()
	match typeof(query_first):
		TYPE_INT:
			# the query type is the given query type, and evaluation starts with the first condition (next item in array)
			match query_first:
				AND:
					var and_conditions = query.slice(1, query.size() - 1)
					for condition in and_conditions:
						var conditions_match = evaluate_query([condition], for_creature, simulated_state)
						if conditions_match == false:
							return false
					return true
				OR:
					var or_conditions = query.slice(1, query.size() - 1)
					for condition in or_conditions:
						var conditions_match = evaluate_query([condition], for_creature, simulated_state)
						if conditions_match == true:
							return true
					return false
				NOT:
					var not_conditions = query.slice(1, query.size() - 1)
					for condition in not_conditions:
						var conditions_match = evaluate_query([condition], for_creature, simulated_state)
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
	
func _evaluate_inner_query(query: Array, for_creature: OGCreature, property: String, simulated_state: Array ) -> Array:
	match query.front():
		HAS:
			var remaining = _evaluate_has_query(query.back(), for_creature, property, simulated_state)
			return remaining
		GREATER_THAN, GREATER_OR_EQUAL, LESS_THAN, LESS_OR_EQUAL, NOT_EQUAL, EQUAL:
			var matches = _evaluate_operator_query(query.front(), for_creature.get(property), query.back())
			return [] if matches else query
		_:
			push_error('Invalid query sent to _evaluate_inner_query')
	return query
	
func _evaluate_operator_query(operator: int, left_val, right_val) -> bool:
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
	
func _evaluate_has_query(query_props: Dictionary, for_creature: OGCreature, property: String, simulated_state: Array) -> Array:
	# This query checks an array property on an creature to see if it contains elements
	# with the given properties, and looks for missing elements in the simulated state
	
	# THEORY
	# THIS SHOULD RETURN A SIMULATED STATE SHOWING WHAT HASN'T BEEN USED TO SATISFY THE HAS QUERY,
	# IN CASE THERE ARE MULTIPLE HAS QUERIES, SO THEY DON'T COUNT THE SAME ITEMS AS HITS
	var return_vals = {
		'still_seeking': {},
		'unused_elements_in_creature': [],
		'unused_elements_in_simulated_state': [],
	}
	
	
	# example seeking_props: { 'material': Item.Material.BONE, 'value': [ GREATER_THAN: 10 ], QUANTITY: 3 }
	# example property: 'inventory'
	var seeking_props = query_props.duplicate(true)
	var items_to_check = for_creature.get(property).duplicate()
#	var cpl_iterator = creature_prop_list.duplicate(true)
	var unused_elements = []

	for item in items_to_check:
		var matched_all_props = true
		if !seeking_props.get(QUANTITY):
			seeking_props[QUANTITY] = 1
		for prop in seeking_props:
			if prop is int and prop == QUANTITY:
				continue
			if typeof(seeking_props[prop]) == TYPE_ARRAY:
				# this is another query to evaluate
				var matches = _evaluate_operator_query(seeking_props[prop][0], item.get(prop), seeking_props[prop][1])
				if matches:
					continue
			elif prop in item:
				if item.get(prop) == seeking_props[prop]:
					continue
			#this item is missing one of the props
			matched_all_props = false
			unused_elements.append(item)
			break
		if matched_all_props:
			seeking_props[QUANTITY] -= 1
			if seeking_props[QUANTITY] <= 0:
				if simulated_state.empty(): 
					return_vals.unused_elements_in_creature = unused_elements
					return return_vals

				
	# now check the simulated state for matching props
#	var sim_has = _find_has_conditions_in_simulated_state(simulated_state)
	var missing_props = _evaluate_query_condition_against_simulated_state(seeking_props, simulated_state)
	if missing_props.empty():
		return []
	return []

# returns a dictionary showing what's missing from the query
func _evaluate_query_condition_against_simulated_state(query_dict: Dictionary, simulated_state: Array) -> Dictionary:
	var remaining = query_dict.duplicate(true)
	for condition in simulated_state:
		match typeof(condition):
			TYPE_ARRAY:
				if condition.empty(): return query_dict
				var operator = condition.front() if typeof(condition.front()) != TYPE_INT else AND
				var simulated_conditions = condition.slice(1, condition.size() - 1)
				match operator:
					AND:
						for cond in simulated_conditions:
							remaining = _evaluate_query_condition_against_simulated_state(remaining, cond)
							if remaining.empty():
								return {}
						return remaining
					OR:
						for cond in simulated_conditions:
							remaining = _evaluate_query_condition_against_simulated_state(query_dict, cond)
							if remaining.empty():
								return {}
						# THIS WILL ONLY RETURN THE MOST RECENT ITERATION, RATHER THAN THE CLOSEST MATCH
						# DOES THAT MATTER?
						return remaining
					NOT:
						# NOT CONDITIONS ARE CONFUSING ME A LITTLE, BUT I THINK WE'RE ONLY GOING FOR A 
						# TRUE/FALSE IN THE END, SO WE ONLY CARE ABOUT EMPTY/NON-EMPTY RETURNS
						for cond in simulated_conditions:
							remaining = _evaluate_query_condition_against_simulated_state(query_dict, cond)
							if remaining.empty():
								return query_dict
						return {}
			TYPE_DICTIONARY:
				var query_found = _evaluate_query_condition_against_simulated_condition(query_dict, condition)
				return query_found
			_:
				push_error('Wrong type sent to _evaluate_query_condition_against_simulated_state')
			
	return {}


# goal looks like: { 'creature.tagged': [ target.HAS, { 'material': Item.Material.BONE } ] }
# returns a dictionary showing HAS state conditions that haven't been satisfied (or empty)
func _evaluate_query_condition_against_simulated_condition(goal_: Dictionary, sim_: Dictionary) -> Dictionary:
	var goal = goal_.duplicate(true)
	var sim = sim_.duplicate(true)
	var return_vals = {
		'still_seeking': goal,
		'unused_elements_in_simulated_state': sim,
	}
	
	
	# ARE THESE CHECKS NECESSARY? WE MIGHT BE DOING THEM BEFORE CALLING THIS FUNCTION
	for goal_key in goal.keys():
		if sim.has(goal_key):
			var goal_query = goal[goal_key]
			var s = sim[goal_key]
			if !(goal_query is Array) or !(s is Array) or !(goal_query.front() is int) or !(s.front() is int):
				push_error('Invalid query sent to _evaluate_query_condition_against_simulated_condition')
			if goal_query.front() == HAS and s.front() == HAS:
	# END OF MAYBE UNNECESSARY CHECKS
				var goal_seeking = goal_query.slice(1, goal_query.size() - 1)
				var sim_contains = s.slice(1, s.size() - 1)
				var index = 0
				# goal_seeking looks like: [{ 'material': Item.Material.BONE }, { 'value': [ LESS_THAN, 50 ], 'weight' 20 }]
				for seeking in goal_seeking:
					# seeking looks like: { 'value': [ LESS_THAN, 50 ], 'weight' 20 }
					var qty_seeking = 1
					var seeking_keys = seeking.keys()
					if QUANTITY in seeking_keys:
						qty_seeking = seeking[QUANTITY]
						seeking_keys.remove(seeking_keys.find(QUANTITY))
					var sim_index = -1
					# sim_contains looks like: [{ 'material': Item.Material.BONE }, { 'value': 50, 'weight' 20 }]
					for contains in sim_contains:
						if typeof(contains) != TYPE_DICTIONARY: continue
						# contains looks like: { 'value': [ LESS_THAN, 50 ], 'weight' 20 }
						var qty_contained = 1
						if QUANTITY in contains:
							qty_contained = contains[QUANTITY]
						if contains.has_all(seeking_keys):
							var properties_match = _compare_properties_of_seeking_and_simulated(seeking, contains)

							if properties_match:
								var qty_removed = min(qty_seeking, qty_contained)
								qty_seeking -= qty_removed
								qty_contained -= qty_removed
								if QUANTITY in contains:
									contains[QUANTITY] = qty_contained
								if !(QUANTITY in contains) or qty_contained <= 0:
									sim_contains[sim_contains.find(contains)] = 'DELETE'
							if qty_seeking <= 0 or qty_contained <=0:
								break
					if qty_seeking <= 0: 
						goal_seeking[index] = {}
					else:
						seeking[QUANTITY] = qty_seeking
					index +=1
				while sim_contains.has('DELETE'):
					sim_contains.remove(sim_contains.find('DELETE'))
				if !sim_contains.empty():
					sim_contains.push_front(s.front())
					sim[goal_key] = sim_contains
				else:
					sim.erase(goal_key)
					print('sim after erase ', sim)
				var unfulfilled_has_conditions = false
				for item in goal_seeking:
					if !item.empty():
						unfulfilled_has_conditions = true
						break
				if !unfulfilled_has_conditions:
					goal.erase(goal_key)
					print('goal after erase ', goal)
				return_vals.still_seeking = goal
				return_vals.unused_elements_in_simulated_state = sim
				print('return_vals ', return_vals)
			elif goal_query.front() == HAS:
				match s.front():
					GREATER_THAN, GREATER_OR_EQUAL, LESS_THAN, LESS_OR_EQUAL, NOT_EQUAL, EQUAL:
						pass
					_:
						push_error('Invalid operator query')
	return return_vals
	
func _compare_properties_of_seeking_and_simulated(seeking: Dictionary, contains: Dictionary) -> bool:
	var all_properties_match = true
	# property looks like: 'value'
	for property in seeking:
		if typeof(property) == TYPE_INT and property == QUANTITY:
			continue
		if typeof(contains[property]) == TYPE_ARRAY:
			push_error('Simulated state cannot contain an operator, values must be concrete')
			continue
		if seeking.get(property) is Array and seeking.get(property)[0] is int:
			var valid = _evaluate_operator_query(seeking[property][0], contains.get(property), seeking[property][1])
			if !valid:
				return false
	return true


func _find_has_conditions_in_simulated_state(sim: Array) -> Array:
	if sim.empty(): 
		return sim
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
# Returns a dictionary describing what elements are still not satisfied
func _evaluate_condition(condition_: Dictionary, for_creature: OGCreature, simulated_state: Array ) -> bool:
	# example conditions: { 'creature.inventory': [ HAS, { 'material': Item.Material.BONE } ] }
	# { 'creature.intelligence': [ MORE_THAN, 10 ] }
	# { 'creature.creature_state: CreatureState.IDLE }
	
	var condition = condition_.duplicate(true)
	for cn in condition:
		var full_condition_name: String = cn
		
		if '.' in full_condition_name:
			var condition_elements = full_condition_name.split('.')
			if condition_elements[0] == 'creature' && condition_elements.size() == 2:
				# this is a check of a property, function, or creature's inventory
				var condition_value = condition[full_condition_name]
				var condition_name = condition_elements[1]
				if typeof(condition_value) == TYPE_ARRAY:
					# the condition value is another query, such as a list of properties for
					# and inventory item, or an operator comparison
#					var creature_value = for_creature.get(condition_name)
					var matches = _evaluate_inner_query(condition_value, for_creature, condition_name, simulated_state)
					if !matches: 
						return false
					continue
				elif for_creature.has_method(condition_name):
					# it's a function
					if for_creature.call(condition_name) == condition_value:
						condition.erase(full_condition_name)
				elif condition_name in for_creature:
					# it's a property
					if for_creature.get(condition_name) == condition_value:
						condition.erase(full_condition_name)
			# WHAT OTHER THINGS COULD CONDITIONS BEGIN WITH?
	return true

#func simulate_creature(creature: OGCreature) -> Dictionary:
#	var simulated_creature = {}
#	for property in creature.get_property_list():
#		simulated_creature[property] = creature.get(property)
#	return simulated_creature

func get_class(): return 'GOAPQueryable'
