extends GutTest

var target = load('res://autoload_global/AIAgent.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var t: AIAgent
var creature: OGCreatureOrc
var goal_entertain_self: GoalEntertainSelf
var goal_feed_self: GoalFeedSelf
var goal_claim_bone: GoalClaimBone

func before_each():
	t = target.new()
	add_child_autofree(t)
	creature = orc.instance()
	add_child_autofree(creature)
	for goal in creature.goals:
		if goal is GoalEntertainSelf:
			goal_entertain_self = goal
		elif goal is GoalFeedSelf:
			goal_feed_self = goal
		elif goal is GoalClaimBone:
			goal_claim_bone = goal

func test__check_goal_validity():
	var state = t.simulate_world_state_for_creature(creature)
	assert_true(t._check_goal_validity(goal_entertain_self, state))
	
	assert_false(t._check_goal_validity(goal_feed_self, state))
	var sandwich = load('res://entity/item/OGItemSandwich.tscn').instance()
	add_child_autofree(sandwich)

	state = t.simulate_world_state_for_creature(creature)
	assert_true(t._check_goal_validity(goal_feed_self, state))

func test__get_best_goal():
	pending()
	
func test__follow_plan():
	pending()
	
func test__run():
	pending()
