extends GutTest

var target = load('res://autoload_global/AIPlanner.gd')

func test_get_plan():
	var t = target.new()
	add_child(t)
	var creature = load('res://entity/creature/orc/OGCreatureOrc.tscn').instance()
	var sandwich = load('res://entity/item/OGItemSandwich.tscn').instance()
	add_child(creature)
	ItemManager.add_child(sandwich)
	var action

	for act in creature.actions:
		if act is ActionEatFood:
			action = act
			break
	var goal
	for g in creature.goals:
		if g is GoalFeedSelf:
			goal = g
			break

	var output = t.get_plan(creature, goal)

	var expected_output = [
		{ 'action': action, 'total_cost': 1 },
	]

	assert_eq_deep(output, expected_output)

	for act in creature.actions:
		act.reset()
	
	var bone = load('res://entity/item/OGItemBone.tscn').instance()
	ItemManager.add_child(bone)
	var act_get
	var act_own	
	for act in creature.actions:
		if act is ActionPickUpItem:
			act_get = act
		elif act is ActionOwnItem:
			act_own = act
	for g in creature.goals:
		if g is GoalClaimBone:
			goal = g
			break
			
	output = t.get_plan(creature, goal)
	
	expected_output = [
		{ 'action': act_get, 'total_cost': 1 },
		{ 'action': act_own, 'total_cost': 2 },
	]
	
	for item in output:
		assert_has([act_get, act_own], item.action)
		
	output.invert()
	for i in [1, 2]:
		assert_eq(output[i-1].total_cost, i)

	bone.free()
	creature.free()
	sandwich.free()
	t.free()
	
func test__path_exists():
	var t = target.new()
	add_child(t)
	var creature = load('res://entity/creature/orc/OGCreatureOrc.tscn').instance()
	var sandwich = load('res://entity/item/OGItemSandwich.tscn').instance()
	add_child(creature)
	ItemManager.add_child(sandwich)
	var action
	for act in creature.actions:
		if act is ActionEatFood:
			action = act
			break
	var goal
	for g in creature.goals:
		if g is GoalFeedSelf:
			goal = g
			break
	var state = t.simulate_world_state_for_creature(creature)

	var root = {
		'desired_state': goal.desired_state().duplicate(true),
		'branching_paths': []
	}
	
	var output = t._find_branching_paths(creature, root, state)

	var expected_output = [
		{
			'action': action,
			'desired_state': {},
			'branching_paths': []
		}
	]
	
	assert_eq_deep(output, expected_output)
	
	var bone = load('res://entity/item/OGItemBone.tscn').instance()
	ItemManager.add_child(bone)

	var act_own
	var act_get
	for act in creature.actions:
		if act is ActionOwnItem:
			act_own = act
		elif act is ActionPickUpItem:
			act_get = act
#		if act_own and act_get: break
	for g in creature.goals:
		if g is GoalClaimBone:
			goal = g
			break
	state = t.simulate_world_state_for_creature(creature)

	expected_output = [
		{
			'action': act_own,
			'desired_state': {
				'creature': {
					'inventory': {
						t.HAS: [
							{ 'material': Item.Material.BONE, t.QUANTITY: 1 }
						]
					}
				}
			},
			'branching_paths': [
				{
					'action': act_get,
					'desired_state': {},
					'branching_paths': []
				},
			]
		},
		{
			'action': act_get,
			'desired_state': {
				'creature': {
					'owned': {
						t.HAS: [
							{ 'material': Item.Material.BONE, t.QUANTITY: 1 }
						]
					}
				}
			},
			'branching_paths': [
				{
					'action': act_own,
					'desired_state': {},
					'branching_paths': []
				},
			]
		}
	]

	root.desired_state = goal.desired_state().duplicate(true)
	output = t._find_branching_paths(creature, root, state.duplicate(true))
	
	var hashed_output = []
	for item in output:
		hashed_output.append(item.hash())
		
	var hashed_expected = []
	for item in expected_output:
		hashed_expected.append(item.hash())
	
	for item in hashed_expected:
		assert_has(hashed_output, item)
	
#	assert_eq_deep(output, expected_output)
			
	bone.free()
	creature.free()
	sandwich.free()
	t.free()
