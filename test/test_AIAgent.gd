extends GutTest

var target = load('res://autoload_global/AIAgent.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var meat = load('res://entity/item/OGItemMeat.tscn')
var bone_item = load('res://entity/item/OGItemBone.tscn')
var region_map = load('res://map/regionmap/RegionMap.tscn')
var t: AIAgent
var map: RegionMap
var creature: OGCreatureOrc
var goal_entertain_self: GoalEntertainSelf
var goal_feed_self: GoalFeedSelf
var goal_claim_bone: GoalClaimBone
var food: OGItemMeat
var bone: OGItemBone
var action_eat_food: ActionEatFood

#func before_all():
#	t = target.new()
#	add_child_autofree(t)
#	map = region_map.instance()
##	var world_tile = OrcGameMapTile.new(1, 1)
##	map.create_tiles(world_tile)
##	world_tile.free()
#	add_child(map)
#	EntityManager.map = map
#
#func after_all():
#	map.free()

func before_each():
	t = target.new()
	add_child_autofree(t)
	map = region_map.instance()
	add_child_autofree(map)
	EntityManager.map = map
	creature = orc.instance()
	add_child_autofree(creature)
	for goal in creature.goals:
		if goal is GoalEntertainSelf:
			goal_entertain_self = goal
		elif goal is GoalFeedSelf:
			goal_feed_self = goal
		elif goal is GoalClaimBone:
			goal_claim_bone = goal
	for action in creature.actions:
		if action is ActionEatFood:
			action_eat_food = action
	food = meat.instance()
	add_child_autofree(food)
	bone = bone_item.instance()
	add_child_autofree(bone)
	

func test__check_goal_validity():
	var state = t.simulate_world_state_for_creature(creature)
	assert_true(t._check_goal_validity(goal_entertain_self, state))
	
	state = t.simulate_world_state_for_creature(creature)
	assert_true(t._check_goal_validity(goal_feed_self, state))
	
	var creature2 = orc.instance()
	add_child_autofree(creature2)
	ItemManager.creature_tag_item(creature2, food)
	state = t.simulate_world_state_for_creature(creature)
	assert_false(t._check_goal_validity(goal_feed_self, state))
	
	creature2.untag_item(food)
	creature.fullness = 100
	state = t.simulate_world_state_for_creature(creature)
	assert_false(t._check_goal_validity(goal_feed_self, state))
	

func test__get_best_goal():
	var state = t.simulate_world_state_for_creature(creature)
	var best_goal = t._get_best_goal(creature, state)
	assert_eq(best_goal, goal_feed_self)
	
	var creature2 = orc.instance()
	add_child_autofree(creature2)
	ItemManager.creature_own_item(creature2, food)
	state = t.simulate_world_state_for_creature(creature)
	best_goal = t._get_best_goal(creature, state)
	assert_eq(best_goal, goal_claim_bone)
	
	ItemManager.creature_own_item(creature2, bone)
	state = t.simulate_world_state_for_creature(creature)
	best_goal = t._get_best_goal(creature, state)
	assert_eq(best_goal, goal_entertain_self)
	
func test__follow_plan():
	pending()
	
func test_run():
	var expected_plan = [
		{ 'action': action_eat_food, 'total_cost': 1 },
	]
	
	t.run(creature)
	assert_eq_deep(expected_plan, creature.current_plan)
	assert_eq(0, creature.current_plan_step)
