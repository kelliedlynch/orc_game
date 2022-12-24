extends GutTest

var target = load('res://autoload_global/AIAgent.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var meat = load('res://entity/item/OGItemMeat.tscn')
var bone_item = load('res://entity/item/OGItemBone.tscn')
var log_item = load('res://entity/item/OGItemLog.tscn')
var built = load('res://entity/built/campfire/OGBuiltCampfire.tscn')
var region_map = load('res://map/regionmap/RegionMap.tscn')
var t: AIAgent
var map: RegionMap
var creature: OGCreatureOrc
var goal_entertain_self: GoalEntertainSelf
var goal_feed_self: GoalFeedSelf
var goal_claim_bone: GoalClaimBone
var goal_construct_built: JobConstructBuilt
var food: OGItemMeat
var bone: OGItemBone
var wood: OGItemLog
var campfire: OGBuiltCampfire
var action_eat_food: ActionEatFood
var action_construct_built: ActionConstructBuilt


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
#		elif goal is JobConstructBuilt:
#			goal_construct_built = goal
	for action in creature.actions:
		if action is ActionEatFood:
			action_eat_food = action
		elif action is ActionConstructBuilt:
			action_construct_built = action
	food = meat.instance()
	add_child_autofree(food)
	bone = bone_item.instance()
	add_child_autofree(bone)
	wood = log_item.instance()
	add_child_autofree(wood)
	campfire = built.instance()
	add_child_autofree(campfire)
	

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
	assert_eq(best_goal.get_class(), 'JobConstructBuilt')
	
	ItemManager.creature_tag_item(creature2, wood)
	state = t.simulate_world_state_for_creature(creature)
	best_goal = t._get_best_goal(creature, state)
	assert_eq(best_goal, goal_claim_bone)
	
	ItemManager.creature_own_item(creature2, bone)
	state = t.simulate_world_state_for_creature(creature)
	best_goal = t._get_best_goal(creature, state)
	assert_eq(best_goal, goal_entertain_self)
	
func test_run():
	var expected_plan = [
		{ 'action': action_eat_food, 'total_cost': 1 },
	]
	
	t.run(creature)
	assert_eq_deep(expected_plan, creature.current_plan)
	assert_eq(0, creature.current_plan_step)
