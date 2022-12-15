extends GdUnitTestSuite

var t = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')


func test__find_has_conditions_in_simulated_state():
	# FINDS SHALLOW HAS CONDITION
	var target = t.new()
	var input = [
		{ 'character.inventory': [ target.HAS, { 'material': 'bone' } ] }
	]
	var output = target._find_has_conditions_in_simulated_state(input)
	var expected_output = input.duplicate(true)
	assert_array(output).is_equal(expected_output)

	# FINDS SHALLOW HAS CONDITION AND EXCLUDES OTHER CONDITIONS
	input = [
		{ 'creature.inventory': [ target.HAS, { 'material': 'bone' } ] },
		{ 'creature.first_name': 'Grug' },
	]
	assert_array(output).is_equal(expected_output)

	# EXCLUDES NON-HAS CONDITIONS
	input = [
		{ 'creature.first_name': 'Grug' }
	]
	output = target._find_has_conditions_in_simulated_state(input)
	assert_array(output).is_empty()

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
	assert_array(output).is_equal(expected_output)

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
	assert_array(output).is_equal(expected_output)

	target.free()

func test__eval_has_state_dicts():
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': 'bone'}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._eval_has_state_dicts(input1, input2)
	assert_dict(output).is_equal(expected_output)
	
	target.free()
