extends WAT.Test

var t = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')


func test__find_has_conditions_in_simulated_state():
	# FINDS SHALLOW HAS CONDITION
	var target = t.new()
	var input = [
		{ 'character.inventory': [ target.HAS, { 'material': 'bone' } ] }
	]
	var output = target._find_has_conditions_in_simulated_state(input)
	var expected_output = input.duplicate(true)
	asserts.is_equal(output.hash(), expected_output.hash())

	# FINDS SHALLOW HAS CONDITION AND EXCLUDES OTHER CONDITIONS
	input = [
		{ 'creature.inventory': [ target.HAS, { 'material': 'bone' } ] },
		{ 'creature.first_name': 'Grug' },
	]
	asserts.is_equal(output.hash(), expected_output.hash())

	# EXCLUDES NON-HAS CONDITIONS
	input = [
		{ 'creature.first_name': 'Grug' }
	]
	expected_output = []
	output = target._find_has_conditions_in_simulated_state(input)
	asserts.is_equal(output.hash(), expected_output.hash())

	# FINDS DEEP HAS CONDITION
	input = [
		target.AND,
		{ 'creature.first_name': 'Grug' },
		[ target.OR,
			{ 'creature.subtype': CreatureSubtype.Subtype.SUBTYPE_ORC },
			{ 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] },
		]
	]
	expected_output = [
		target.AND,
		# TODO: OR CONDITIONS ON ACTION OUTPUTS--MAKE SURE THE PLANNER DOESN'T GET STUCK BECAUSE
		# THE CURRENT WORLD STATE RESULTS IN THE WRONG OR OUTPUT
		[ target.OR,
			{ 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] },
		]
	]
	output = target._find_has_conditions_in_simulated_state(input)
	asserts.is_equal(output.hash(), expected_output.hash())

	# FINDS DEEP AND EXTRA DEEP HAS CONDITIONS AT MULTIPLE NESTING LEVELS
	input = [
		{ 'creature.first_name': 'Grug' },
		[ target.OR,
			{ 'creature.subtype': CreatureSubtype.Subtype.SUBTYPE_ORC },
			{ 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] },
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
			{ 'creature.tagged': [ target.HAS, { 'material': 'bone' } ] },
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
	asserts.is_equal(output.hash(), expected_output.hash())

	target.free()

func test__evaluate_query_condition_against_simulated_condition():
	# SIMPLE COMPARISON OF IDENTICAL DICTIONARIES
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': 'bone'}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._evaluate_query_condition_against_simulated_condition(input1, input2)
	asserts.is_equal(output.hash(), expected_output.hash())
	
	# QUERIES WITH MULTIPLE ITEMS, MULTIPLE PROPERTIES, AND OPERATORS
	input1 = {
		'character.inventory': [ target.HAS, 
									{ 'material': 'bone', target.QUANTITY: 3 }, 
									{ 'value': [ target.LESS_THAN, 100 ] }
		],
		'character.tagged': [ target.HAS,
									{ 'material': 'bone', 'value': [ target.GREATER_THAN, 20 ]},
									{ 'item_name': 'rock', target.QUANTITY: 8 }
		]
	}
	input2 = {
		'character.inventory': [ target.HAS, 
									{ 'material': 'bone', target.QUANTITY: 3 }, 
									{ 'value': 50 }
		],
		'character.tagged': [ target.HAS,
									{ 'material': 'bone', 'value': 30},
									{ 'item_name': 'rock', target.QUANTITY: 10 },
									{ 'weight': 50, target.QUANTITY: 1}
		]
	}
	output = target._evaluate_query_condition_against_simulated_condition(input1, input2)
	print('output ', output)
	asserts.is_equal(output.hash(), expected_output.hash())
	
	target.free()

func test__evaluate_query_condition_against_simulated_state():
	# SIMPLE COMPARISON OF IDENTICAL DICTIONARIES
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': 'bone'}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._evaluate_query_condition_against_simulated_state(input1, input2)
	asserts.is_equal(output.hash(), expected_output.hash())
	
	# QUERIES WITH MULTIPLE ITEMS, MULTIPLE PROPERTIES, AND OPERATORS
	input1 = {
		'character.inventory': [ target.HAS, { 'material': 'bone', target.QUANTITY: 2, 'value': 30}]
	}
	input2 = {
		'character.inventory': [ target.HAS, 
									{ 'material': 'bone', target.QUANTITY: 3 }, 
									{ 'value': 50, 'material': 'bone' },
									{ 'value': 100, 'material': 'bone' }
		],
		'character.tagged': [ target.HAS,
									{ 'material': 'bone', 'value': 20},
									{ 'item_name': 'rock', target.QUANTITY: 10 },
									{ 'weight': 50, target.QUANTITY: 1}
		]
	}
	output = target._evaluate_query_condition_against_simulated_state(input1, input2)
	asserts.is_equal(output.hash(), expected_output.hash())
	
	target.free()

# TODO NEXT: MORE TESTS FOR MORE COMPLEX QUERIES AND STATES
func test__evaluate_has_query():
	var target = t.new()
	var creature = OGCreatureOrc.new()
	creature.add_to_inventory(OGItemBone.new())
	var seeking = { 'material': 'bone' }
	var property = '_inventory'
	var simulated_state = []
	
	var output = target._evaluate_has_query(seeking, creature, property, simulated_state)
	var expected_output = true
	asserts.is_equal(output, expected_output)
