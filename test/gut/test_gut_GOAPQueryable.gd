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

func test_apply_transform_step_to_world_state():
	var t = target.new()
	var transform = t.ADD
	var sim = [{ 'material': Item.Material.BONE}]
	var world = []
	var expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	var output = t._apply_transform_step_to_world_state(transform, sim, world)
	
	assert_eq_deep(output, expected_output)
	
	sim = [{ 'material': Item.Material.BONE}, { 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE}]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 3 }]
	output = t._apply_transform_step_to_world_state(transform, sim, world)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = [{ 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t._apply_transform_step_to_world_state(transform, sim, world)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 1
	world = 10
	expected_output = 9
	output = t._apply_transform_step_to_world_state(transform, sim, world)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	expected_output = 11
	output = t._apply_transform_step_to_world_state(transform, sim, world)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	sim = Vector2(1, 1)
	world = Vector2(3, 4)
	expected_output = Vector2(4, 5)
	output = t._apply_transform_step_to_world_state(transform, sim, world)

	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 10
	world = 1
	expected_output = 1
	output = t._apply_transform_step_to_world_state(transform, sim, world)

	assert_eq_deep(output, expected_output)
	
	t.free()

func test_apply_transform_to_world_state():
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
	var output = t.apply_transform_to_world_state(sim, world)

	assert_eq_deep(output, expected_output)
	
	sim = {
		'creature': {
			'intelligence': {
				t.SUBTRACT: 2
			},
			'inventory': {
				t.ADD: [{ 'material': Item.Material.BONE }]
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
	
	output = t.apply_transform_to_world_state(sim, world)
	
	assert_eq_deep(output, expected_output)
	
	sim = {
		'creature': {
			'intelligence': {
				t.SUBTRACT: 2,
				t.ADD: 4,
			},
			'inventory': {
				t.ADD: [{ 'material': Item.Material.BONE }],
				t.SUBTRACT: [{ 'material': Item.Material.BONE }],
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

	output = t.apply_transform_to_world_state(sim, world)
	
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
	var transform = {
		'creature': {
			'inventory': {
				t.ADD: [item]
			}
		}
	}
	var result = t.apply_transform_to_world_state(transform, world)
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
	
	# TODO: Should this actually return false? How do we handle operator queries that go alongside
	# other queries? Currently it is working differently from LESS OR EQUAL below, so I need to figure
	# that out.
	query = [{ 'material': Item.Material.BONE }, { 'material': Item.Material.BONE, t.QUANTITY: [t.GREATER_THAN, 2]} ]
	result = t._eval_has_condition(query, state)
	
	assert_false(result)

	query = [{ 'material': Item.Material.BONE, t.QUANTITY: [t.LESS_OR_EQUAL, 2] }, { 'material': Item.Material.BONE }]
	result = t._eval_has_condition(query, state)
	
	assert_false(result)

# This test wanted LESS_OR_EQUAL to return true if the previous query item "took away" an item, but
# that's really hard to do, and I'm not actually sure I want it to work that way.	
#	query = [{ 'material': Item.Material.BONE }, { 'material': Item.Material.BONE, t.QUANTITY: [t.LESS_OR_EQUAL, 2] }]
#	result = t._eval_has_condition(query, state)
#
#	assert_true(result)
	
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

func test_remove_satisfied_conditions_from_query():
	var t = target.new()
	var query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID
		}
	}
	var state = query
	var expected_output = {}
	var output = t.remove_satisfied_conditions_from_query(query, state)
	
	assert_eq_deep(output, expected_output)
	
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			'subtype': Creature.Subtype.SUBTYPE_ORC
		}
	}
	state = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID
		}
	}
	expected_output = {
		'creature': {
			'subtype': Creature.Subtype.SUBTYPE_ORC
		}
	}
	output = t.remove_satisfied_conditions_from_query(query, state)
	
	assert_eq_deep(output, expected_output)
	
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			'subtype': Creature.Subtype.SUBTYPE_ORC,
			'intelligence': [t.GREATER_THAN, 10],
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE }
				]
			}
		}
	}
	state = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			'intelligence': 12,
			'inventory': [
					{ 'material': Item.Material.BONE, 'value': 100 }
				]
		}
	}
	expected_output = {
		'creature': {
			'subtype': Creature.Subtype.SUBTYPE_ORC
		}
	}
	output = t.remove_satisfied_conditions_from_query(query, state)
	
	assert_eq_deep(output, expected_output)
	
	query = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			t.NOT: { 'subtype': Creature.Subtype.SUBTYPE_ORC },
			'intelligence': [t.LESS_THAN, 10],
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE, t.QUANTITY: [t.LESS_THAN, 3] },
					{ 'material': Item.Material.WOOD, t.QUANTITY: 4 }
				]
			}
		}
	}
	state = {
		'creature': {
			'type': Creature.Type.TYPE_HUMANOID,
			'intelligence': 12,
			'inventory': [
					{ 'material': Item.Material.BONE, 'value': 100 },
					{ 'material': Item.Material.BONE, t.QUANTITY: 3 },
					{ 'material': Item.Material.WOOD, t.QUANTITY: 2 },
				]
		}
	}
	expected_output = {
		'creature': {
			'intelligence': [t.LESS_THAN, 10],
			'inventory': {
				t.HAS: [
					{ 'material': Item.Material.BONE, t.QUANTITY: [t.LESS_THAN, 3] },
					{ 'material': Item.Material.WOOD, t.QUANTITY: 2 }
				]
			}
		}
	}
	output = t.remove_satisfied_conditions_from_query(query, state)
	
	assert_eq_deep(output, expected_output)
	
	t.free()

