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
	var untagged = get_tree().get_nodes_in_group(Group.Item.UNTAGGED_ITEMS)

	var output = t.get_plan(creature, goal)

	var expected_output = [
		{ 'action': action, 'total_cost': 1 },
	]

	assert_eq_deep(output, expected_output)

#	var bone = load('res://entity/item/OGItemBone.tscn').instance()
#	ItemManager.add_child(bone)
#	var state = t.simulate_world_state_for_creature(creature)
#	var act_own
#	var act_get
#	for act in creature.actions:
#		if act is ActionOwnItem:
#			act_own = act
#		elif act is ActionPickUpItem:
#			act_get = act
##		if act_own and act_get: break
#	for g in creature.goals:
#		if g is GoalClaimBone:
#			goal = g
#			break
##	var step1desired = 
#	expected_output = {
#		'desired_state': goal.desired_state(),
#		'trigger_conditions': {},
#		'branching_paths': [
#			{
#				'action': act_own,
#				'desired_state': t.remove_satisfied_conditions_from_query(act_own.applied_transform(), state),
#				'trigger_conditions': {},
#				'branching_paths': [
#					{
#						'action': act_get,
#						'desired_state': {},
#						'trigger_conditions': {},
#						'branching_paths': []
#					},
#				]
#			},
#			{
#				'action': act_get,
#				'desired_state':  t.remove_satisfied_conditions_from_query(act_get.applied_transform(), state),
#				'trigger_conditions': {},
#				'branching_paths': [
#					{
#						'action': act_own,
#						'desired_state': {},
#						'trigger_conditions': {},
#						'branching_paths': []
#					},
#				]
#			}
#		],
#	}
#	output = t.get_plan(creature, goal)
#	prints('output', output)
#	prints('expected_output', expected_output)
#
#
#
#	bone.free()
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

	var untagged = get_tree().get_nodes_in_group(Group.Item.UNTAGGED_ITEMS)
	
	var root = {
		'desired_state': goal.desired_state().duplicate(),
		'trigger_conditions': {},
		'branching_paths': []
	}
	
	var output = t._path_exists(creature, root, state)

	var expected_output = {
		'desired_state': goal.desired_state(),
		'trigger_conditions': {},
		'branching_paths': [
			{
				'action': action,
				'desired_state': {},
				'trigger_conditions': {},
				'branching_paths': []
			}
		],
	}
	
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
#	var step1desired = 
	expected_output = {
		'desired_state': goal.desired_state(),
		'trigger_conditions': {},
		'branching_paths': [
			{
				'action': act_own,
				'desired_state': t.remove_satisfied_conditions_from_query(act_own.applied_transform(), state),
				'trigger_conditions': {},
				'branching_paths': [
					{
						'action': act_get,
						'desired_state': {},
						'trigger_conditions': {},
						'branching_paths': []
					},
				]
			},
			{
				'action': act_get,
				'desired_state':  t.remove_satisfied_conditions_from_query(act_get.applied_transform(), state),
				'trigger_conditions': {},
				'branching_paths': [
					{
						'action': act_own,
						'desired_state': {},
						'trigger_conditions': {},
						'branching_paths': []
					},
				]
			}
		],
	}
	state = t.simulate_world_state_for_creature(creature)
	root.desired_state = goal.desired_state().duplicate()
	output = t._path_exists(creature, root, state)
	prints('output', output)
	prints('expected_output', expected_output)
	
			
			
	bone.free()
	creature.free()
	sandwich.free()
	t.free()
