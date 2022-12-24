extends GutTest

var target = load('res://autoload_global/AIAgent.gd')
var orc = load('res://entity/creature/orc/OGCreatureOrc.tscn')
var meat = load('res://entity/item/OGItemMeat.tscn')
var bone_item = load('res://entity/item/OGItemBone.tscn')
var region_map = load('res://map/regionmap/RegionMap.tscn')
var t: AIAgent
var map: RegionMap
var creature: OGCreatureOrc
var food: OGItemMeat
var bone: OGItemBone
var action_eat_food: ActionEatFood
var action_wander: ActionWander

#func before_all():

#	var world_tile = OrcGameMapTile.new(1, 1)
#	map.create_tiles(world_tile)
#	world_tile.free()


func before_each():
	t = target.new()
	add_child_autofree(t)
	map = region_map.instance()
	add_child_autofree(map)
	EntityManager.map = map
	creature = orc.instance()
	add_child_autofree(creature)
	for action in creature.actions:
		if action is ActionEatFood:
			action_eat_food = action
		elif action is ActionWander:
			action_wander = action
	food = meat.instance()
	add_child_autofree(food)
	bone = bone_item.instance()
	add_child_autofree(bone)
	
func test_action_wander():
	var start_location = creature.location
	action_wander.perform()

	assert_ne(start_location, creature.location)
