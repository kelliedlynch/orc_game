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

const QUANTITY = 'QueryTransformQUANTITY'

const ADD = 'TransformADD'
const SUBTRACT = 'TransformSUBTRACT'

const QueryConditionals: Array = [AND, OR, NOT]
const QueryOperators: Array = [GREATER_THAN, GREATER_OR_EQUAL, LESS_THAN, LESS_OR_EQUAL]
const TransformOperators: Array = [ADD, SUBTRACT]
const ArrayTypes: Array = [TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY, TYPE_STRING_ARRAY, TYPE_VECTOR2_ARRAY]
const PropertyValueTypes: Array = [TYPE_STRING, TYPE_BOOL, TYPE_REAL, TYPE_INT, TYPE_VECTOR2]

# simulate_object cannot simulate methods; anything that must be queried needs to be stored as a property
func simulate_object(obj: Object) -> Dictionary:
	var sim = {}
	if !obj:
		return sim
	for property in obj.get_property_list():
		var type = property.type
		if property.name == 'script' or property.name == 'script/source':
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
	elif type == TYPE_INT or type == TYPE_STRING or type == TYPE_VECTOR2 or type == TYPE_REAL:
		return prop
	else:
		return null

# TODO: SIMULATE OTHER WORLD PROPERTIES WE NEED TO LOOK AT
func simulate_world_state_for_creature(creature: OGCreature):
	var state = {}
	state['creature'] = simulate_object(creature)

func apply_simulated_state_to_world_state(world_: Dictionary, sim_: Dictionary):
	var world = world_.duplicate(true)
	var sim = sim_.duplicate(true)
	for key in sim:

		var stype = typeof(sim[key])

		if stype == TYPE_DICTIONARY:
			if key in world:
				var wtype = typeof(world[key])
				if wtype == TYPE_DICTIONARY:
					world[key] = apply_simulated_state_to_world_state(world[key], sim[key])
					continue
			if key in TransformOperators:
				world = _apply_transform_to_world_state(key, world, sim[key])
			else:
				for simkey in sim[key]:
					if simkey in TransformOperators:
						world[key] = _apply_transform_to_world_state(simkey, world[key], sim[key][simkey])
					else:
						push_error("Invalid transform format in simulated state")
		else:
			world[key] = sim[key]
#		else:
#			push_error('Invalid key %s in simulated state' % key)
	return world
			
func _apply_transform_to_world_state(transform: String, world_, sim):
	var world = world_
	var wtype = typeof(world)
	var stype = typeof(sim)
	if transform == ADD or transform == SUBTRACT:
		if (wtype in ArrayTypes):
			if (stype in ArrayTypes):
				for sitem in sim:
					var sitype = typeof(sitem)
					if sitype == TYPE_DICTIONARY:
						world = _apply_dictionary_transform_to_world_array(transform, sitem, world)
			elif stype == TYPE_DICTIONARY:
				world = _apply_dictionary_transform_to_world_array(transform, sim, world)
		elif (wtype == TYPE_REAL or wtype == TYPE_INT or wtype == TYPE_VECTOR2):
			if transform == ADD:
				world = world + sim
			else:
				if world >= sim:
					world = world - sim
		elif wtype == TYPE_DICTIONARY:
			world = world_.duplicate()
			for key in sim:
				if transform == ADD:
					if key in world:
						push_error('Cannot ADD to dictionary; property already exists')
						return world_
					world[key] = sim[key]
				else:
					if !world.has(key):
						push_error('Cannot SUBTRACT from dictionary; property already exists')
						return world_
					if world[key] != sim[key]:
						push_error('Cannot SUBTRACT from dictionary; property values do not match')
						return world_
					world.erase(key)
		else:
			push_error('Invalid type %s for %s transform' % [stype, transform])
			return world_
	else:
		push_error('Invalid transform %s in simulated state' % transform)
		return world_
	return world

func _apply_dictionary_transform_to_world_array(transform: String, dict: Dictionary, world: Array):
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
	var query = query_.duplicate(true)
	var state = state_.duplicate(true)
	var passed = false	
	for key in query:
		passed = _eval_query_key(query[key], state[key])
		if !passed: break
	return passed
	
func _eval_query_key(query, state):
	var qtype = typeof(query) 
	var stype = typeof(state) 
	if qtype == TYPE_DICTIONARY:
		if query.has(HAS) and state is Array:
			return _eval_has_condition(query[HAS], state)
		for condition in QueryConditionals:
			if condition in query:
				return _eval_conditional_query(condition, query[condition], state)
		if stype == TYPE_DICTIONARY:
			for key in query:
				var passed = _eval_query_key(query[key], state[key])
				if !passed: return false
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
	
func _eval_conditional_query(condition: String, query: Dictionary, state: Dictionary):
	if condition == AND:
		for key in query:
			var passes = _eval_query_key(query[key], state[key])
			if !passes: 
				return false
	elif condition == OR:
		var one_passed = false
		for key in query:
			var passes = _eval_query_key(query[key], state[key])
			if passes:
				one_passed = true
				break
		if !one_passed: 
			return false
	elif condition == NOT:
		for key in query:
			var passes = _eval_query_key(query[key], state[key])
			if !passes: 
				return false
	return true

func _eval_has_condition(has_: Array, state_: Array, is_OR_query = false) -> bool:
	var has = has_.duplicate()
	var state = state_.duplicate()
	var has_index = -1
	for has_item in has:
		has_index += 1
		if !has_item.has(QUANTITY):
			has_item[QUANTITY] = 1
			has[has_index][QUANTITY] = 1
		
		if typeof(has_item[QUANTITY]) == TYPE_ARRAY:
			var operator = has_item[QUANTITY][0]
			var has_qty = has_item[QUANTITY][1]
			for state_item in state:
				var state_qty = state_item[QUANTITY]
				var passed = _eval_operator_query(operator, state_qty, has_qty)
				if operator == GREATER_THAN or operator == GREATER_OR_EQUAL:
					if passed: 
						if is_OR_query: return true
						has[has_index] = null
						break
					else:
						has_item[QUANTITY][1] -= state_qty
				elif operator == LESS_THAN or operator == LESS_OR_EQUAL:
					if passed:
						has_item[QUANTITY][1] -= state_qty
						has[has_index] = null
						continue
					if is_OR_query: return false
					has[has_index] = 'operator query fail'
					break
		else:
			var state_index = -1
			for state_item in state:
				state_index +=1
				if !state_item.has(QUANTITY):
					state_item[QUANTITY] = 1
					state[state_index][QUANTITY] = 1
				var all_props_match = true
				for prop in has_item:
					if !state_item.has(prop):
						all_props_match = false
						break
				if all_props_match:
					var qty_found = min(has_item[QUANTITY], state_item[QUANTITY])
					if qty_found > 0 and is_OR_query: return true
					has[has_index][QUANTITY] -= qty_found
					state[state_index][QUANTITY] -= qty_found
					if state[state_index][QUANTITY] <= 0:
						state[state_index] = null
					if has[has_index][QUANTITY] <= 0:
						has[has_index] = null
						break
		while state.has(null):
			state.remove(state.find(null))
	while has.has(null):
		has.remove(has.find(null))
	if has.empty():
		return true
	return false

func any_conditions_satisfied(conditions: Dictionary, state: Dictionary) -> bool:
	for key in conditions:
		if key in state:
			var passed = _search_for_any_match(conditions[key], state[key])
			if passed: return true
	return false

func _search_for_any_match(query, state) -> bool:
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
