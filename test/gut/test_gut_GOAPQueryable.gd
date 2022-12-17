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
	var output = t.apply_dictionary_transform_to_world_array(transform, dictionary, world)
	
	assert_eq_deep(output, expected_output)
	
	world = [{ 'material': Item.Material.BONE }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	output = t.apply_dictionary_transform_to_world_array(transform, dictionary, world)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	dictionary = { 'material': Item.Material.BONE }
	world = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t.apply_dictionary_transform_to_world_array(transform, dictionary, world)

	assert_eq_deep(output, expected_output)

	transform = t.SUBTRACT
	dictionary = { 'material': Item.Material.BONE, t.QUANTITY: 2 }
	world = [{ 'material': Item.Material.BONE}]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t.apply_dictionary_transform_to_world_array(transform, dictionary, world)

	assert_eq_deep(output, expected_output)

	t.free()

func test_apply_transform_to_world_state():
	var t = target.new()
	var transform = t.ADD
	var sim = [{ 'material': Item.Material.BONE}]
	var world = []
	var expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	var output = t.apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	sim = [{ 'material': Item.Material.BONE}, { 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE}]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 3 }]
	output = t.apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = [{ 'material': Item.Material.BONE}]
	world = [{ 'material': Item.Material.BONE, t.QUANTITY: 2 }]
	expected_output = [{ 'material': Item.Material.BONE, t.QUANTITY: 1 }]
	output = t.apply_transform_to_world_state(transform, world, sim)
	
	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 1
	world = 10
	expected_output = 9
	output = t.apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	expected_output = 11
	output = t.apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.ADD
	sim = Vector2(1, 1)
	world = Vector2(3, 4)
	expected_output = Vector2(4, 5)
	output = t.apply_transform_to_world_state(transform, world, sim)

	assert_eq_deep(output, expected_output)
	
	transform = t.SUBTRACT
	sim = 10
	world = 1
	expected_output = 1
	output = t.apply_transform_to_world_state(transform, world, sim)

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
	
	
	t.free()
