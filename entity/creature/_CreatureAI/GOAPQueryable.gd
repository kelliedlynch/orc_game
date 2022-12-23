extends Node
class_name GOAPQueryable

# Base class for Actions and Goals, implements query language for conditions and results

const AND = 'QueryLangAND'
const OR = 'QueryLangOR'
const NOT = 'QueryLangNOT'
const HAS = 'QueryLangHAS'
const GREATER_THAN = 'QueryLangGREATER_THAN'
const GREATER_OR_EQUAL = 'QueryLangGREATER_OR_EQUAL'
const LESS_THAN = 'QueryLangLESS_THAN'
const LESS_OR_EQUAL = 'QueryLangLESS_OR_EQUAL'
const EQUAL = 'QueryLangEQUAL'

const QUANTITY = 'QueryTransformQUANTITY'

const ADD = 'TransformADD'
const SUBTRACT = 'TransformSUBTRACT'

# These are used to signal when an action can be passed a specific thing to act on
const VARIABLE_PROPERTY = 'TransformVARIABLE_PROPERTY'
const VARIABLE_VALUE = 'TransformVARIABLE_VALUE'

# used for testing and development, makes a query return true or false regardless
const OVERRIDE = 'QueryOVERRIDE'

const QueryConditionals: Array = [AND, OR, NOT]
const QueryOperators: Array = [GREATER_THAN, GREATER_OR_EQUAL, LESS_THAN, LESS_OR_EQUAL]
const TransformOperators: Array = [ADD, SUBTRACT]
const ArrayTypes: Array = [TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY, TYPE_STRING_ARRAY, TYPE_VECTOR2_ARRAY]
const PropertyValueTypes: Array = [TYPE_STRING, TYPE_BOOL, TYPE_REAL, TYPE_INT, TYPE_VECTOR2]

const SimulatedPropertyTypes: Array = [TYPE_DICTIONARY, 'OGEntity']
#const prohibited_properties = ['script', 'script/source', 'viewport', 'root_node']
# simulate_object cannot simulate methods; anything that must be queried needs to be stored as a property
func simulate_object(obj: Object) -> Dictionary:
	var sim = {}
	if !obj:
		return sim
	var list = obj.script.get_script_property_list()
	for property in list:
		var type = typeof(property)
		if type == TYPE_BOOL:
			pass
		var simtypes = SimulatedPropertyTypes + ArrayTypes + PropertyValueTypes
		if !(type in simtypes): 
			continue
		if type == TYPE_OBJECT:
			sim[property.name] = simulate_object(obj.get(property.name))
			continue
		var simprop = simulate_property(obj.get(property.name))
		sim[property.name] = simprop
	return sim

func simulate_property(prop):
	var type = typeof(prop)
	if type == TYPE_INT_ARRAY or type == TYPE_STRING_ARRAY or type == TYPE_VECTOR2_ARRAY:
		return prop
	if type == TYPE_ARRAY:
		var sim = []
		for item in prop:
			var itemtype = typeof(item)
			if itemtype == TYPE_OBJECT:
				sim.append(simulate_object(item))
				continue
			sim.append(simulate_property(item))
		return sim
	elif type == TYPE_DICTIONARY:
		var sim = {}
		for prop_name in prop:
			var itemtype = typeof(prop[prop_name])
			if itemtype == TYPE_OBJECT:
				sim[prop_name] = simulate_object(prop[prop_name])
				continue
			sim[prop_name] = simulate_property(prop[prop_name])
	elif type in PropertyValueTypes:
		return prop
	else:
		return null

# TODO: SIMULATE OTHER WORLD PROPERTIES WE NEED TO LOOK AT
func simulate_world_state_for_creature(creature: OGCreature) -> Dictionary:
	var state = {}
	state['creature'] = simulate_object(creature)
	var groups = [ Group.Item.UNTAGGED_ITEMS, Group.Item.UNOWNED_ITEMS, Group.Item.AVAILABLE_ITEMS]
	state['items'] = {}
	for group in groups:
		var items = get_tree().get_nodes_in_group(group)
		var simitems = []
		for item in items:
			simitems.append(simulate_object(item))
		state['items'][group] = simitems
			
#	state['items'] = {
#		Group.Item.UNTAGGED_ITEMS: get_tree().get_nodes_in_group(Group.Item.UNTAGGED_ITEMS),
#		Group.Item.UNOWNED_ITEMS: get_tree().get_nodes_in_group(Group.Item.UNOWNED_ITEMS),
#		Group.Item.AVAILABLE_ITEMS: get_tree().get_nodes_in_group(Group.Item.AVAILABLE_ITEMS),
#	}
	return state

func apply_transform_to_world_state(transform: Dictionary, state_: Dictionary) -> Dictionary:
	var state = state_.duplicate(true)
	for key in transform:
		var t_type = typeof(transform[key])
		if t_type == TYPE_DICTIONARY:
			if key in state and state[key] is Dictionary:
				state[key] = apply_transform_to_world_state(transform[key], state[key])
				pass
			elif key in TransformOperators:
				state = _apply_transform_step_to_world_state(key, transform[key], state)
				pass
			else:
				for t_key in transform[key]:
					if t_key in TransformOperators:
						state[key] = _apply_transform_step_to_world_state(t_key, transform[key][t_key], state[key])
						pass
					else:
						state[key] = apply_transform_to_world_state(transform[key], state[key])
						pass
		elif t_type in PropertyValueTypes:
			state[key] = transform[key]
	return state
			
func _apply_transform_step_to_world_state(transform_type: String, transform, state_):
	var state = state_.duplicate(true) if state_ is Array or state_ is Dictionary else state_
	var s_type = typeof(state)
	var t_type = typeof(transform)
	if transform_type == ADD or transform_type == SUBTRACT:
		if (s_type in ArrayTypes):
			if (t_type in ArrayTypes):
				for t_item in transform:
					var t_item_type = typeof(t_item)
					if t_item_type == TYPE_DICTIONARY:
						state = _apply_dictionary_transform_to_world_array(transform_type, t_item, state)
			elif t_type == TYPE_DICTIONARY:
				state = _apply_dictionary_transform_to_world_array(transform_type, transform, state)
		elif (s_type == TYPE_REAL or s_type == TYPE_INT or s_type == TYPE_VECTOR2):
			if transform_type == ADD:
				state = state + transform
			else:
				if state >= transform:
					state = state - transform
		elif s_type == TYPE_DICTIONARY:
			state = state_.duplicate(true)
			for key in transform:
				if transform_type == ADD:
					if key in state:
						push_error('Cannot ADD to dictionary; property already exists')
						return state_
					state[key] = transform[key]
				else:
					if !state.has(key):
						push_error('Cannot SUBTRACT from dictionary; property already exists')
						return state_
					if state[key] != transform[key]:
						push_error('Cannot SUBTRACT from dictionary; property values do not match')
						return state_
					state.erase(key)
		else:
			push_error('Invalid type %s for %s transform name' % [t_type, transform_type])
			return state_
	else:
		push_error('Invalid transform name %s in simulated state' % transform_type)
		return state_
	return state

func _apply_dictionary_transform_to_world_array(transform: String, dict: Dictionary, world_: Array):
	var world = world_.duplicate(true)
	var t_qty = 1
	var d_keys = dict.keys()
	if dict.has(QUANTITY):
		t_qty = dict[QUANTITY]
	else:
		dict[QUANTITY] = 1
	var existing_transformed = false
	var i = -1
	for witem in world:
		i += 1
		if typeof(witem) != TYPE_DICTIONARY:
			continue
		if !witem.has(QUANTITY):
			witem[QUANTITY] = 1
		if witem.has_all(d_keys):
			if transform == ADD:
				witem[QUANTITY] += t_qty
			elif transform == SUBTRACT:
				if witem[QUANTITY] >= t_qty:
					witem[QUANTITY] -= t_qty
					if witem[QUANTITY] <= 0:
						world[i] = null
				else: continue
			existing_transformed = true
			break
	while null in world:
		world.erase(null)
	if !existing_transformed and transform == ADD:
		world.append(dict)
	return world

func remove_satisfied_conditions_from_query(query_: Dictionary, state: Dictionary) -> Dictionary:
	var query = query_.duplicate(true)
	for key in query.keys():
		var scrubbed = _remove_satisfied_query_key(query[key], state[key])
		if scrubbed.empty(): 
			query.erase(key)
		else:
			query[key] = scrubbed
		pass
	pass
	return query
		
func _remove_satisfied_query_key(query_, state_):
	var query = query_.duplicate(true) if query_ is Array or query_ is Dictionary else query_
	var state = state_.duplicate(true) if state_ is Array or state_ is Dictionary else state_
	var qtype = typeof(query)
	var stype = typeof(state)
	if qtype == TYPE_DICTIONARY:
		if query.has(HAS) and state is Array:
			var return_val = _remove_satisfied_has_conditions(query[HAS], state)
			if return_val.empty():
				return {}
			return { HAS: return_val }
		var query_copy = query.duplicate(true)
		for condition in query:
			pass
			if condition in QueryConditionals:
				var passes = _eval_conditional_query(condition, query[condition], state)
				if passes: query_copy.erase(condition)
			else:
				if !(condition in state): continue
				var remaining = _remove_satisfied_query_key(query[condition], state[condition])
				if ((remaining is Array or remaining is Dictionary) and remaining.empty())\
					or remaining == null: 
					pass
					query_copy.erase(condition)
				else:
					pass
					query_copy[condition] = remaining
		pass
		return query_copy
	elif qtype == TYPE_ARRAY and stype in PropertyValueTypes:
		var passes = _eval_operator_query(query[0], state, query[1])
		if passes: return null
	elif qtype in PropertyValueTypes and stype in PropertyValueTypes:
		var passes = _eval_operator_query("", query, state)
		if passes: return null
	elif (qtype is Array and stype in ArrayTypes) or (qtype in ArrayTypes and stype is Array)\
			or (qtype in ArrayTypes and qtype == stype) or (qtype is Array and stype is Array):
		# Theoretically, this could cause a bug because hash values aren't necessarily unique,
		# but it's terribly unlikely
		if hash(query) == hash(state):
			return []
	return query
		
func _remove_satisfied_has_conditions(has_: Array, state_: Array) -> bool:
	var has = has_.duplicate(true)
	var state = state_.duplicate(true)
	var has_index = -1
	for has_item in has:
		has_index += 1
		if !has_item.has(QUANTITY):
			has_item[QUANTITY] = 1
			has[has_index][QUANTITY] = 1
		var operator = GREATER_OR_EQUAL
		var has_qty = has_item[QUANTITY]
		if typeof(has_item[QUANTITY]) == TYPE_ARRAY:
			operator = has_item[QUANTITY][0]
			has_qty = has_item[QUANTITY][1]

		var state_index = -1
		for state_item in state:
			state_index += 1
			if !state_item.has(QUANTITY):
				state_item[QUANTITY] = 1
				state[state_index][QUANTITY] = 1
			if !state_item.has_all(has_item.keys()): 
				continue
			var props_match = true
			for key in has_item:
				if key == QUANTITY:
					continue
				if has_item[key] != state_item[key]:
					props_match = false
					break
			if props_match == false:
				continue	
			var state_qty = state_item[QUANTITY]
			var passed = _eval_operator_query(operator, state_qty, has_qty)
			if operator == GREATER_THAN or operator == GREATER_OR_EQUAL:
				if !passed:
					has_qty -= state_qty
				else:
					has[has_index] = null
					break
			elif operator == LESS_THAN or operator == LESS_OR_EQUAL:
				if passed:
					has_qty -= state_qty
				else:
					has_qty = has[has_index][QUANTITY]
					has_item = 'operator query fail'
					break
		if operator == LESS_OR_EQUAL or operator == LESS_THAN:
			if !(has_item is String and has_item == 'operator query fail'):
				if has[has_index][QUANTITY] is Array and has_qty == has[has_index][QUANTITY][1]:
					has[has_index] = null
				elif has[has_index][QUANTITY] is int and has_qty == has[has_index][QUANTITY]:
					has[has_index] = null
		else:
			if has[has_index] and typeof(has[has_index][QUANTITY]) == TYPE_ARRAY:
				has[has_index][QUANTITY][1] = has_qty
			elif has[has_index]:
				has[has_index][QUANTITY] = has_qty
		while state.has(null):
			state.remove(state.find(null))
	while has.has(null):
		has.remove(has.find(null))
	pass
	return has

func _eval_operator_query(operator: String, l_val, r_val) -> bool:
	if operator == GREATER_THAN:
		return l_val > r_val
	elif operator == GREATER_OR_EQUAL:
		return l_val >= r_val
	elif operator == LESS_THAN:
		return l_val < r_val
	elif operator == LESS_OR_EQUAL:
		return l_val <= r_val
	else:
		return l_val == r_val

func eval_query(query_: Dictionary, state_: Dictionary):
	if query_.has(OVERRIDE): return query_[OVERRIDE]
	if query_.empty(): return true
	var query = query_.duplicate(true)
	var state = state_.duplicate(true)

	var passed = false
	for key in query:
		if key in QueryConditionals:
			passed = _eval_conditional_query(key, query[key], state)
		else:
			passed = _eval_query_key(query[key], state[key])
		if !passed: break
	return passed
	
func _eval_query_key(query_, state_):
	if query_ is Dictionary and query_.has(OVERRIDE): return query_.OVERRIDE
	var query = query_.duplicate(true) if query_ is Array or query_ is Dictionary else query_
	var state = state_.duplicate(true) if state_ is Array or state_ is Dictionary else state_
	var qtype = typeof(query) 
	var stype = typeof(state) 
	if qtype == TYPE_DICTIONARY:
		if query.has(HAS) and state is Array:
			return _eval_has_condition(query[HAS], state)
		var passes = false
		for condition in query:
			if condition in QueryConditionals:
				passes = _eval_conditional_query(condition, query[condition], state)
				if !passes: return false
			elif stype == TYPE_DICTIONARY:
				if state.has(condition) or query.has(NOT):
					passes = _eval_query_key(query[condition], state[condition])
				else: passes = false
				if !passes: return false
		return true
	elif qtype == TYPE_ARRAY and stype in PropertyValueTypes:
		return _eval_operator_query(query[0], state, query[1])
	elif qtype in PropertyValueTypes and stype in PropertyValueTypes:
		return _eval_operator_query("", query, state)
	elif (qtype is Array and stype in ArrayTypes) or (qtype in ArrayTypes and stype is Array)\
			or (qtype in ArrayTypes and qtype == stype) or (qtype is Array and stype is Array):
		# Theoretically, this could cause a bug because hash values aren't necessarily unique,
		# but it's terribly unlikely
		return hash(query) == hash(state)
	
func _eval_conditional_query(condition: String, query_: Dictionary, state_: Dictionary):
	if query_ is Dictionary and query_.has(OVERRIDE): return query_.OVERRIDE
	var query = query_.duplicate(true) 
	var state = state_.duplicate(true)
	if condition == AND:
		for key in query:
			if !(key in state): return false
			var passes = _eval_query_key(query[key], state[key])
			if !passes: 
				return false
		return true
	elif condition == OR:
		for key in query:
			if !(key in state): continue
			var passes = _eval_query_key(query[key], state[key])
			if passes:
				return true
		return false
	elif condition == NOT:
		for key in query:
			if !(key in state): continue
			var passes = _eval_query_key(query[key], state[key])
			if passes: 
				return false
		return true

func _eval_has_condition(has_: Array, state_: Array, is_OR_query = false) -> bool:
	var has = has_.duplicate(true)
	var state = state_.duplicate(true)
	
	var has_index = -1
	for has_item in has:
		has_index += 1

		if !has_item.has(QUANTITY):
			has_item[QUANTITY] = 1
			has[has_index][QUANTITY] = 1
		
		var operator = GREATER_OR_EQUAL
		var has_qty = has_item[QUANTITY]
		if typeof(has_item[QUANTITY]) == TYPE_ARRAY:
			operator = has_item[QUANTITY][0]
			has_qty = has_item[QUANTITY][1]
		var state_index = -1
		for state_item in state:
			state_index += 1
			if !state_item.has(QUANTITY):
				state_item[QUANTITY] = 1
				state[state_index][QUANTITY] = 1
			if !state_item.has_all(has_item.keys()): 
				continue
			var props_match = true
			for key in has_item:
				if key == QUANTITY:
					continue
				if has_item[key] != state_item[key]:
					props_match = false
					break
			if props_match == false:
				continue
			var state_qty = state_item[QUANTITY]
			var passed = _eval_operator_query(operator, state_qty, has_qty)
			if operator == GREATER_THAN or operator == GREATER_OR_EQUAL:
				if passed == true: 
					if is_OR_query == true: 
						return true
					if has_qty >= state_qty:
						state[state_index] = null
					else:
						state_item[QUANTITY] -= has_qty
					has[has_index] = null
					
					break
				else:
					has_qty -= state_qty
			elif operator == LESS_THAN or operator == LESS_OR_EQUAL:
				if passed == true:
					has_qty -= state_qty
#					has[has_index] = null
					continue
				else:
					# REMOVED AN IS_OR_QUERY CHECK HERE THAT MIGHT BREAK THINGS
					has_qty = has[has_index][QUANTITY]
					has_item = 'operator query fail'
					break
		if operator == LESS_OR_EQUAL or operator == LESS_THAN:
			if !(has_item is String and has_item == 'operator query fail'):
				if has[has_index][QUANTITY] is Array and has_qty == has[has_index][QUANTITY][1]:
					has[has_index] = null
				elif has[has_index][QUANTITY] is int and has_qty == has[has_index][QUANTITY]:
					has[has_index] = null
		else:
			if has[has_index] and typeof(has[has_index][QUANTITY]) == TYPE_ARRAY:
				has[has_index][QUANTITY][1] = has_qty
			elif has[has_index]:
				has[has_index][QUANTITY] = has_qty
		while state.has(null):
			state.remove(state.find(null))
	while has.has(null):
		has.remove(has.find(null))
	if has.empty():
		return true
	return false

func any_conditions_satisfied(conditions: Dictionary, state: Dictionary) -> bool:
	if conditions is Dictionary and conditions.has(OVERRIDE): return conditions.OVERRIDE
	for key in conditions:
		if key in state:
			var passed = _search_for_any_match(conditions[key], state[key])
			if passed: return true
	return false

func _search_for_any_match(query, state) -> bool:
	if query is Dictionary and query.has(OVERRIDE): return query.OVERRIDE
	var qtype = typeof(query) 
	var stype = typeof(state) 
	if qtype == TYPE_DICTIONARY:
		if query.has(HAS) and state is Array:
			return _eval_has_condition(query[HAS], state, true)
		if AND in query:
			return _eval_conditional_query(OR, query[AND], state)
		if stype == TYPE_DICTIONARY:
			for key in query:
				if key in state:
					var passed = _search_for_any_match(query[key], state[key])
					if passed: return true
	elif qtype == TYPE_ARRAY and stype in PropertyValueTypes:
		return _eval_operator_query(query[0], state, query[1])
	elif qtype in PropertyValueTypes and stype in PropertyValueTypes:
		return _eval_operator_query("", query, state)
	elif (qtype is Array and stype in ArrayTypes) or (qtype in ArrayTypes and stype is Array)\
			or (qtype in ArrayTypes and qtype == stype) or (qtype is Array and stype is Array):
		# Theoretically, this could cause a bug because hash values aren't necessarily unique,
		# but it's terribly unlikely
		return hash(query) == hash(state)
	return false

func get_class(): return 'GOAPQueryable'
