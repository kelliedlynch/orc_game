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

const QueryOperators: Array = [AND, OR, NOT, HAS, GREATER_THAN, GREATER_OR_EQUAL, LESS_THAN,
										LESS_OR_EQUAL, QUANTITY]
const TransformOperators: Array = [ADD, SUBTRACT, QUANTITY]

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
		if simprop: sim[property.name] = simprop
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

func apply_simulated_state_to_world_state(world: Dictionary, sim: Dictionary):
	for key in sim:
		var type = typeof(sim[key])
		# key looks like 'creature'
		if key in world:
			if typeof(world[key]) != type:
				push_error('Invalid format for %s in simulated state')
			if type == TYPE_DICTIONARY:
				# simkey looks like SUBTRACT
				for simkey in sim[key]:
					if simkey in TransformOperators:
						world[key] = apply_transform_to_world_state(simkey, world[key], sim[key][simkey])
					else:
						world[key] = apply_simulated_state_to_world_state(world[key], sim[key])
			else:
				world[key] = sim[key]
		else:
			push_error('Invalid key %s in simulated state' % key)
	return world
			
func apply_transform_to_world_state(transform: String, world_, sim):
	var world = world_
	var wtype = typeof(world)
	var stype = typeof(sim)
	if wtype != stype:
		push_error('Invalid type %s for transform on %s' % [stype, wtype])
		return world_
	if transform == ADD or transform == SUBTRACT:
		if (wtype == TYPE_ARRAY or wtype == TYPE_INT_ARRAY or wtype == TYPE_REAL_ARRAY or
					wtype == TYPE_STRING_ARRAY or wtype == TYPE_VECTOR2_ARRAY):
			for sitem in sim:
				var sitype = typeof(sitem)
				if sitype == TYPE_DICTIONARY:
					world = apply_dictionary_transform_to_world_array(transform, sitem, world)
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

func apply_dictionary_transform_to_world_array(transform: String, dict: Dictionary, world: Array):
	var t_qty = 1
	var d_keys = dict.keys()
	if dict.has(QUANTITY):
		t_qty = dict[QUANTITY]
	else:
		dict[QUANTITY] = 1
	var existing_transformed = false
	var i = 0
	for witem in world:
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
				else: continue
			existing_transformed = true
			break
	if !existing_transformed and transform == ADD:
		world.append(dict)
	return world

func get_class(): return 'GOAPQueryable'
