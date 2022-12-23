extends GutTest

var target = load('res://autoload_global/AIAgent.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var sandwich = load('res://entity/item/OGItemSandwich.tscn')
var bone_item = load('res://entity/item/OGItemBone.tscn')
var region_map = load('res://map/regionmap/RegionMap.tscn')
var t: AIAgent
var creature: OGCreatureOrc
var food: OGItemSandwich
var bone: OGItemBone
var action_eat_food: ActionEatFood
var action_wander: ActionWander

func before_each():
	t = target.new()
	add_child_autofree(t)
	creature = orc.instance()
	add_child_autofree(creature)
	for action in creature.actions:
		if action is ActionEatFood:
			action_eat_food = action
		elif action is ActionWander:
			action_wander = action
	food = sandwich.instance()
	add_child_autofree(food)
	bone = bone_item.instance()
	add_child_autofree(bone)
	
func test_action_wander():
	var start_location = creature.location
	var map = region_map.instance()
	CreatureManager.map = map
	action_wander.perform()

	assert_ne(start_location, creature.location)
	
	map.free()
