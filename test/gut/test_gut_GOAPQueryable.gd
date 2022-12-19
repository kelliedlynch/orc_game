extends GutTest

var target = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')

func test_simulate_object():
	var t = target.new()
	var obj = OGCreatureOrc.new()
	var item = OGItemBone.new()
	obj.add_to_inventory(item)
	var sim = t.simulate_object(obj)

	assert_typeof(sim, TYPE_DICTIONARY)
	assert_true(!sim.empty())
	assert_eq(sim.inventory[0].instance_name, item.instance_name)
	
	item.free()
	obj.free()
	t.free()

func test_apply_dictionary_transform_to_world_array():
	var t = target.new()
	var transform = t.ADD
	var dictionary = { 'material': Item.Material.BONE }
	var world = []
	var expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	var output = t._apply_dictionary_transform_to_world_array(transform, dictionary, world)
	
	assert_eq_deep(output, expected_output)
	
	world = [{ 'material': Item.Material.BONE }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	output = t._apply_dictionary_transform_to_world_array(transform, dictionary, world)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	dictionary = { 'material': Item.Material.BONE }
	world = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t._apply_dictionary_transform_to_world_array(transform, dictionary, world)

	assert_eq_deep(output, expected_output)

	transform = t.SUBTRACT
	dictionary = { 'material': Item.Material.BONE, t.QUANTITY: 2 }
	world = [{ 'material': Item.Material.BONE}]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t._apply_dictionary_transform_to_world_array(transform, dictionary, world)

	assert_eq_deep(output, expected_output)

	t.free()

func test_apply_transform_to_world_state():
	var t = target.new()
	var transform = t.ADD
	var sim = [{ 'material': Item.Material.BONE}]
	var world = []
	var expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	var output = t._apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	sim = [{ 'material': Item.Material.BONE}, { 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE}]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 3 }]
	output = t._apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = [{ 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t._apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 1
	world = 10
	expected_output = 9
	output = t._apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	expected_output = 11
	output = t._apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	sim = Vector2(1, 1)
	world = Vector2(3, 4)
	expected_output = Vector2(4, 5)
	output = t._apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 10
	world = 1
	expected_output = 1
	output = t._apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	t.free()

func test_apply_simulated_state_to_world_state():
	var t = target.new()
	var world = {
		'creature': {
			'inventory': [],
			'intelligence': 10,
			'first_name': 'Frank',
		}
	}
	var sim = {
		'creature': {
			t.ADD: {
				'last_name': 'Smith',
			}
		}
	}
	var expected_output = {
		'creature': {
			'inventory': [],
			'intelligence': 10,
			'first_name': 'Frank',
			'last_name': 'Smith',
		}
	}
	var output = t.apply_simulated_state_to_world_state(world, sim)

	assert_eq_deep(output, expected_output)
	
	sim = {
		'creature': {
			'intelligence': {
				t.SUBTRACT: 2
			},
			'inventory': {
				t.ADD: { 'material': Item.Material.BONE }
			}
		}
	}
	expected_output = {
		'creature': {
			'inventory': [ { 'material': Item.Material.BONE, t.QUANTITY: 1 } ],
			'intelligence': 8,
			'first_name': 'Frank',
		}
	}
	
	output = t.apply_simulated_state_to_world_state(world, sim)
	
	assert_eq_deep(output, expected_output)
	
	sim = {
		'creature': {
			'intelligence': {
				t.SUBTRACT: 2,
				t.ADD: 4,
			},
			'inventory': {
				t.ADD: { 'material': Item.Material.BONE },
				t.SUBTRACT: { 'material': Item.Material.BONE },
			},
			t.ADD: {
				'last_name': 'Smith',
			},
			t.SUBTRACT: {
				'first_name': 'Frank',
			}
		}
	}
	expected_output = {
		'creature': {
			'inventory': [],
			'intelligence': 12,
			'last_name': 'Smith',
		}
	}

	output = t.apply_simulated_state_to_world_state(world, sim)
	
	assert_eq_deep(output, expected_output)
	
	t.free()

func test_add_simulated_object_to_simulated_object():
	var t = target.new()
	var c = OGCreatureOrc.new()
	var i = OGItemBone.new()
	var obj = t.simulate_object(c)
	var item = t.simulate_object(i)
	var world = {
		'creature': obj
	}
	var sim = {
		'creature': {
			'inventory': {
				t.ADD: item
			}
		}
	}
	var result = t.apply_simulated_state_to_world_state(world, sim)
	assert_typeof(result, TYPE_DICTIONARY)
	assert_eq(result['creature']['inventory'].size(), 1)
	assert_eq(result['creature']['inventory'][0]['material'], Item.Material.BONE)
	
	i.free()
	c.free()
	t.free()

func test_eval_has_condition():
	var t = target.new()
	var query = [{ 'material': Item.Material.BONE }]
	var state = [{ 'material': Item.Material.BONE , t.QUANTITY: 3 }]
	var result = t._eval_has_condition(query, state)
	
	assert_true(result)
	
	query = [{ 'material': Item.Material.BONE }, { 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	state = [{ 'material': Item.Material.BONE, t.QUANTITY: 3 }]
	result = t._eval_has_condition(query, state)
	
	assert_true(result)
	
	query = [{ 'material': Item.Material.BONE, t.QUANTITY: [t.GREATER_THAN, 2]}, { 'material': Item.Material.BONE } ]
	result = t._eval_has_condition(query, state)
	
	assert_false(result)

	query = [{ 'material': Item.Material.BONE, t.QUANTITY: [t.LESS_OR_EQUAL, 3] }, { 'material': Item.Material.BONE }]
	result = t._eval_has_condition(query, state)
	
	assert_false(result)
	
	t.free()

func test_eval_query():
	var t = target.new()
	var obj = OGCreatureOrc.new()
	var item = OGItemBone.new()
	obj.add_to_inventory(item)
	var sim_obj = t.simulate_object(obj)
	sim_obj.inventory[0][t.QUANTITY] = 3
	var state = {
		'creature': sim_obj
	}
	var query = {
		'creature': {
			'subtype': Creature.Subtype.SUBTYPE_ORC
		}
	}
	var result = t.eval_query(query, state)
	
	assert_true(result)
	
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			'subtype': Creature.Subtype.SUBTYPE_ORC,
			'build_power': [t.GREATER_THAN, 1],
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE },
					{ 'material': Item.Material.BONE, t.QUANTITY: 2 },
				]
			}
		}
	}
	result = t.eval_query(query, state)
	
	assert_true(result)
	
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			t.NOT: {
				'subtype': Creature.Subtype.SUBTYPE_DWARF,
			},
			t.NOT: {
				'first_name': 'Florence'
			},
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE },
					{ 'material': Item.Material.BONE, t.QUANTITY: 2 },
				]
			},
			t.NOT: {
				'inventory': {
					t.HAS: [
						{ 'material': Item.Material.STONE },
					]
				}
			}
		}
	}
	result = t.eval_query(query, state)
	
	assert_true(result)
	
	state['creature']['subtype'] = Creature.Subtype.SUBTYPE_DWARF
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			t.NOT: {
				'subtype': Creature.Subtype.SUBTYPE_DWARF,
				'first_name': 'Florence',
				'inventory': {
					t.HAS: [
						{ 'material': Item.Material.STONE },
					]
				}
			},
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE },
					{ 'material': Item.Material.BONE, t.QUANTITY: 2 },
				]
			},

		}
	}
	result = t.eval_query(query, state)
	
	assert_false(result)
	
	item.free()
	obj.free()
	t.free()
	
func test_any_conditions_satisfied():
	var t = target.new()
	var action = {
		'creature': {
			'intelligence': [t.GREATER_THAN, 1],
			'last_name': 'Smith'
		}
	}
	var state = {
		'creature': {
			'intelligence': 2,
			'weight': 15,
			'first_name': 'Francis'
		}
	}
	var result = t.any_conditions_satisfied(action, state)
	
	assert_true(result)
	
	t.free()
