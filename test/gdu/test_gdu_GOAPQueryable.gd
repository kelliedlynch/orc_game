extends GdUnitTestSuite

var t = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')


func test__find_has_conditions_in_simulated_state():
	# FINDS SHALLOW HAS CONDITION
	var target = t.new()
	var input = [
		{ 'character.inventory': [ target.HAS, { 'material': Item.Material.BONE } ] }
	]
	var output = target._find_has_conditions_in_simulated_state(input)
	var expected_output = input.duplicate(true)
	assert_array(output).is_equal(expected_output)

	# FINDS SHALLOW HAS CONDITION AND EXCLUDES OTHER CONDITIONS
	input = [
		{ 'creature.inventory': [ target.HAS, { 'material': Item.Material.BONE } ] },
		{ 'creature.first_name': 'Grug' },
	]
	assert_array(output).is_equal(expected_output)

	# EXCLUDES NON-HAS CONDITIONS
	input = [
		{ 'creature.first_name': 'Grug' }
	]
	expected_output = []
	output = target._find_has_conditions_in_simulated_state(input)
	assert_array(output).is_equal(expected_output)

	# FINDS DEEP HAS CONDITION
	input = [
		target.AND,
		{ 'creature.first_name': 'Grug' },
		[ target.OR,
			{ 'creature.subtype': CreatureType.Subtype.SUBTYPE_ORC },
			{ 'creature.tagged': [ target.HAS, { 'material': Item.Material.BONE } ] },
		]
	]
	expected_output = [
		target.AND,
		[ target.OR,
			{ 'creature.tagged': [ target.HAS, { 'material': Item.Material.BONE } ] },
		]
	]
	output = target._find_has_conditions_in_simulated_state(input)
	assert_array(output).is_equal(expected_output)

	# FINDS DEEP AND EXTRA DEEP HAS CONDITIONS AT MULTIPLE NESTING LEVELS
	input = [
		{ 'creature.first_name': 'Grug' },
		[ target.OR,
			{ 'creature.subtype': CreatureType.Subtype.SUBTYPE_ORC },
			{ 'creature.tagged': [ target.HAS, { 'material': Item.Material.BONE } ] },
		],
		{ 'creature.owned': [ target.HAS, {'material': 'wood'}]},
		[ target.NOT,
			[ target.OR,
				{ 'creature.intelligence': [ target.GREATER_THAN, 5]},
				[ target.AND,
					{ 'creature.location': [ target.NOT_EQUAL, Vector2(-1, -1)]},
					{ 'creature.inventory': [ target.HAS,
											{
												'material': 'silk',
												target.QUANTITY: 5,
											},
					]}
				]
			]
		]
	]
	expected_output = [
		[ target.OR,
			{ 'creature.tagged': [ target.HAS, { 'material': Item.Material.BONE } ] },
		],
		{ 'creature.owned': [ target.HAS, {'material': 'wood'}]},
		[ target.NOT,
			[ target.OR,
				[ target.AND,
					{ 'creature.inventory': [ target.HAS,
											{
												'material': 'silk',
												target.QUANTITY: 5,
											},
					]}
				]
			]
		]
	]
	output = target._find_has_conditions_in_simulated_state(input)
	assert_array(output).is_equal(expected_output)

	target.free()

func test__evaluate_query_condition_against_simulated_condition():
	# SIMPLE COMPARISON OF IDENTICAL DICTIONARIES
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': Item.Material.BONE}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._evaluate_query_condition_against_simulated_condition(input1, input2)
	assert_dict(output).is_equal(expected_output)
	
	# QUERIES WITH MULTIPLE ITEMS, MULTIPLE PROPERTIES, AND OPERATORS
	input1 = {
		'character.inventory': [ target.HAS, 
									{ 'material': Item.Material.BONE, target.QUANTITY: 3 }, 
									{ 'value': [ target.LESS_THAN, 100 ] }
		],
		'character.tagged': [ target.HAS,
									{ 'material': Item.Material.BONE, 'value': [ target.GREATER_THAN, 20 ]},
									{ 'item_name': 'rock', target.QUANTITY: 8 }
		]
	}
	input2 = {
		'character.inventory': [ target.HAS, 
									{ 'material': Item.Material.BONE, target.QUANTITY: 3 }, 
									{ 'value': 50 }
		],
		'character.tagged': [ target.HAS,
									{ 'material': Item.Material.BONE, 'value': 30},
									{ 'item_name': 'rock', target.QUANTITY: 10 },
									{ 'weight': 50, target.QUANTITY: 1}
		]
	}
	output = target._evaluate_query_condition_against_simulated_condition(input1, input2)
	print('output ', output)
	assert_dict(output).is_equal(expected_output)
	
	target.free()

func test__evaluate_query_condition_against_simulated_state():
	# SIMPLE COMPARISON OF IDENTICAL DICTIONARIES
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': Item.Material.BONE}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._evaluate_query_condition_against_simulated_state(input1, input2)
	assert_dict(output).is_equal(expected_output)
	
	# QUERIES WITH MULTIPLE ITEMS, MULTIPLE PROPERTIES, AND OPERATORS
	input1 = {
		'character.inventory': [ target.HAS, { 'material': Item.Material.BONE, target.QUANTITY: 2, 'value': 30}]
	}
	input2 = {
		'character.inventory': [ target.HAS, 
									{ 'material': Item.Material.BONE, target.QUANTITY: 3 }, 
									{ 'value': 50, 'material': Item.Material.BONE },
									{ 'value': 100, 'material': Item.Material.BONE }
		],
		'character.tagged': [ target.HAS,
									{ 'material': Item.Material.BONE, 'value': 20},
									{ 'item_name': 'rock', target.QUANTITY: 10 },
									{ 'weight': 50, target.QUANTITY: 1}
		]
	}
	output = target._evaluate_query_condition_against_simulated_state(input1, input2)
	assert_dict(output).is_equal(expected_output)
	
	target.free()

func test__evaluate_has_query():
	# SIMPLE TEST AGAINST CREATURE INVENTORY
	var target = t.new()
	var creature = OGCreatureOrc.new()
	var items = [OGItemBone.new()]
	creature.add_to_inventory(items[0])
	var seeking = { 'material': Item.Material.BONE }
	var property = 'inventory'
	var simulated_state = []
	
	var output = target._evaluate_has_query(seeking, creature, property, simulated_state)
	var expected_output = true
	assert_bool(output).is_equal(expected_output)
	
	items = [OGItemBone.new(), OGItemBone.new(), OGItemBone.new()]
	items[0].quantity = 4
	items[1].value = 100
	items[2].value = 50
	items[2].quantity = 2
	for item in items:
		creature.add_to_inventory(item)
		
	# ADD QUANTITY
	seeking = {
		'material': Item.Material.BONE,
		target.QUANTITY: 7,
	}
	output = target._evaluate_has_query(seeking, creature, property, simulated_state)
	assert_bool(output).is_equal(expected_output)
	
	# ADD QUANTITY, PROPERTY, AND OPERATOR QUERY
	seeking = {
		'material': Item.Material.BONE,
		target.QUANTITY: 3,
		'value': [ target.GREATER_THAN, 20 ],
	}
	output = target._evaluate_has_query(seeking, creature, property, simulated_state)
	assert_bool(output).is_equal(expected_output)
	
	for item in creature.inventory:
		item.free()
	creature.free()
	target.free()

func test_evaluate_query():
	# SIMPLEST QUERY, CHECK FOR A SINGLE ITEM
	var target = t.new()
	var creature = OGCreatureOrc.new()
	var items = [OGItemBone.new()]
	creature.add_to_inventory(items[0])
	var query = [
		{ 'creature.inventory': [ target.HAS, { 'material': Item.Material.BONE} ] }
	]
	var simulated_state = []
	var expected_output = true
	
	var output = target.evaluate_query(query, creature, simulated_state)
	assert_bool(output).is_equal(expected_output)
	
	# NESTED QUERY WITH OPERATOR QUERIES
	query = [
		{ 'creature.subtype': CreatureType.Subtype.SUBTYPE_ORC },
		{ 'creature.build_power': [ target.GREATER_THAN, 1 ] },
		[ target.OR,
			{ 'creature.first_name': 'Francis'},
			{ 'creature.inventory': [ target.HAS, { 'material': Item.Material.BONE } ] },
		],
		[ target.NOT,
			{ 'creature.inventory': [ target.HAS, { 'quality': 'masterwork' } ] },
		]
	]
	
	output = target.evaluate_query(query, creature, simulated_state)
	assert_bool(output).is_equal(expected_output)
	
	# NESTED QUERY WITH OPERATOR QUERIES AND SIMULATED STATE
	query = [
		{ 'creature.subtype': CreatureType.Subtype.SUBTYPE_ORC },
		{ 'creature.build_power': [ target.GREATER_THAN, 1 ] },
		[ target.OR,
			{ 'creature.first_name': 'Francis'},
			{ 'creature.inventory': [ target.HAS, { 'material': Item.Material.BONE, target.QUANTITY: 2 } ] },
		],
		[ target.NOT,
			{ 'creature.inventory': [ target.HAS, { 'quality': 'masterwork' } ] },
		]
	]
	simulated_state = [
		[ target.AND, 
			{ 'creature.inventory': [ target.HAS, { 'material': Item.Material.BONE } ] },
			{ 'creature.weight': 100 }
		]
	]
	
	output = target.evaluate_query(query, creature, simulated_state)
	assert_bool(output).is_equal(expected_output)
	
	for item in creature.inventory:
		item.free()
	creature.free()
	target.free()
