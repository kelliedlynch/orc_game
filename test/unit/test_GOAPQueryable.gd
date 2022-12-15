extends GutTest

var t = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')


func test__find_has_conditions_in_simulated_state():
	var target = autofree(t.new())
	var input = [
		{ 'character.inventory': [ target.HAS, { 'material': 'bone' } ] }
	]
	var output = target._find_has_conditions_in_simulated_state(input)

	assert_eq_deep(output, input)

func test__eval_has_state_dicts():
	var target = t.new()
	var input1 = {
		'character.inventory': [ target.HAS, { 'material': 'bone'}]
	}
	var input2 = input1
	var expected_output = {}
	var output = target._eval_has_state_dicts(input1, input2)
	assert_eq_deep(output, expected_output)
	
	target.free()
