extends GutTest

var t = load('res://entity/creature/_CreatureAI/GOAPQueryable.gd')


func test__find_has_conditions_in_simulated_state():
	var target = autofree(t.new())
	var input = [
		{ 'character.inventory': [ target.HAS, { 'material': 'bone' } ] }
	]
	var output = target._find_has_conditions_in_simulated_state(input)

	assert_eq_deep(output, input)
