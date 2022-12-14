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
		GREATER_THAN:
			return for_creature.get(property) > query.back()
		GREATER_OR_EQUAL:
			return for_creature.get(property) >= query.back()
		LESS_THAN:
			return for_creature.get(property) < query.back()
		LESS_OR_EQUAL:
			return for_creature.get(property) <= query.back()
		NOT_EQUAL:
			return for_creature.get(property) != query.back()
		EQUAL, _:
			return for_creature.get(property) == query.back()
	return false
	
func _evaluate_has_query(prop_list: Dictionary, for_creature: OGCreature, property: String, simulated_state: Array) -> bool:
	# This query checks an array property on an creature to see if it contains elements
	# with the given properties
	# example prop_list: { 'material': 'bone', 'value': [ GREATER_THAN: 10 ], QUANTITY: 3 }
	var creature_prop_list = for_creature.get(property)
	var qty_needed = 1
	var qty_found = 0
	if QUANTITY in prop_list:
		qty_needed = prop_list[QUANTITY]
	for item in creature_prop_list:
		var matched_all_props = true
		for prop in prop_list:
			if prop == QUANTITY:
				continue
			if typeof(prop_list[prop]) == TYPE_ARRAY:
				# this is another query to evaluate
				pass
				
			if prop in item:
				if item.get(prop) == prop_list[prop]:
					continue
			#this item is missing one of the props
			matched_all_props = false
		if matched_all_props:
			qty_found += 1
			if qty_found >= qty_needed:
				return true
	if simulated_state.size() == 0: return qty_found >= qty_needed
	# now check the simulated state for matching props
	var sim_has = _find_has_conditions_in_simulated_state(simulated_state)
	
# 	[
#		AND,
#			{ 'creature_inventory': [ HAS, 
#									{ 'material': 'bone' },
#									{ 'material': 'wood, 'type': 'pedestal' }
#								]}
#			{ 'creature_inventory': [ NOT,
#									[ HAS,
#										{ 'item_name': 'cursed_sword' }
#									]
#								]}
#	]
	
	
	
	for condition in simulated_state:
		pass
	return false

func _find_has_conditions_in_simulated_state(sim: Array):
	var sim_first = sim.front()

#		[ target.NOT,
#			[ target.OR,
#				{ 'creature.intelligence': [ target.GREATER_THAN, 5]},
#				[ target.AND,
#					{ 'creature.location': [ target.NOT_EQUAL, Vector2(-1, -1)]},
#					{ 'creature.inventory': [ target.HAS,
#											{
#												'material': 'silk',
#												target.QUANTITY: 5,
#											},
#					]}
#				]
#			]
#		]


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
#				_:
#					push_error('Using inner query term in outer query')
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
								push_error("Can't compare property values as arrays; use 'has' notation instead")
					TYPE_ARRAY:
						var found = _find_has_conditions_in_simulated_state(array_element)
						if !found.empty():
							return_array.append(found)
		_:
			push_error('Simulated state has invalid syntax')
	return return_array

			# TODO: DOCUMENT IN QUERY API THAT YOU CAN'T COMPARE PARAMETERS WITH ARRAY VALUES,
			# INSTEAD YOU NEED TO USE 'HAS' QUERIES TO LOOK AT CONTENTS OF ARRAYS
#					TYPE_ARRAY:
#						if !(typeof(condition.front())) != TYPE_INT:
#
#							continue
#						var found = _find_has_conditions_in_simulated_state(condition)
#						if !found.empty():
#							return_array.append(found)
#					TYPE_DICTIONARY:
#						var found_in_dict = {}
#						for condition_name in condition:
#							if typeof(condition[condition_name]) != TYPE_ARRAY:
#								continue
#							var found = _find_has_conditions_in_simulated_state(condition[condition_name])
#							if !found.empty():
#								found_in_dict[condition_name] = found
#						if !found_in_dict.empty():
#							return_array.append(found_in_dict)
#					_:
#						continue
#			if return_array.size() > 0:
#				return return_array



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
