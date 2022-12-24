extends GutTest

var target = load('res://autoload_global/AIPlanner.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var meat = load('res://entity/item/OGItemMeat.tscn')
var bone_item = load('res://entity/item/OGItemBone.tscn')
var t: AIPlanner
var creature: OGCreatureOrc
var goal_entertain_self: GoalEntertainSelf
var goal_feed_self: GoalFeedSelf
var goal_claim_bone: GoalClaimBone
var food: OGItemMeat
var bone: OGItemBone
var action_eat_food: ActionEatFood
var action_pick_up_item: ActionPickUpItem
var action_own_item: ActionOwnItem

#func before_all():

#	map = region_map.instance()
#	var world_tile = OrcGameMapTile.new(1, 1)
#	map.create_tiles(world_tile)
#	world_tile.queue_free()
#	add_child_autofree(map)
#	EntityManager.map = map

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
	for action in creature.actions:
		if action is ActionEatFood:
			action_eat_food = action
		if action is ActionPickUpItem:
			action_pick_up_item = action
		if action is ActionOwnItem:
			action_own_item = action
	food = meat.instance()
	add_child_autofree(food)
	bone = bone_item.instance()
	add_child_autofree(bone)
	
	
func test_get_plan():
	var output = t.get_plan(creature, goal_feed_self)

	var expected_output = [
		{ 'action': action_eat_food, 'total_cost': 1 },
	]

	assert_eq_deep(output, expected_output)

			
	output = t.get_plan(creature, goal_claim_bone)
	
	assert_eq(output.size(), 2)
	
	for item in output:
		assert_has([action_pick_up_item, action_own_item], item.action)

	output.invert()
	for i in [1, 2]:
		assert_eq(output[i-1].total_cost, i)

	
func test__path_exists():

	var state = t.simulate_world_state_for_creature(creature)

	var root = {
		'desired_state': goal_feed_self.desired_state().duplicate(true),
		'branching_paths': []
	}
	
	var output = t._find_branching_paths(creature, root, state)

	var expected_output = [
		{
			'action': action_eat_food,
			'desired_state': {},
			'branching_paths': []
		}
	]
	
	assert_eq_deep(output, expected_output)
	

#	state = t.simulate_world_state_for_creature(creature)

	expected_output = [
		{
			'action': action_own_item,
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
					'action': action_pick_up_item,
					'desired_state': {},
					'branching_paths': []
				},
			]
		},
		{
			'action': action_pick_up_item,
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
					'action': action_own_item,
					'desired_state': {},
					'branching_paths': []
				},
			]
		}
	]

	root.desired_state = goal_claim_bone.desired_state().duplicate(true)
	output = t._find_branching_paths(creature, root, state.duplicate(true))

	assert_eq_deep(output, expected_output)
