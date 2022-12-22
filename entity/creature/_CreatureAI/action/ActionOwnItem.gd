extends GOAPAction
class_name ActionOwnItem

# CREATURE WILL CLAIM AN ITEM, ADD IT TO ITS OWNED ITEMS, AND STORE THE ITEM APPROPRIATELY
# IN ORDER OF PRIORITY:
# - CARRY AND USE ITEM IF USABLE
# - PLACE IN HOME IF HOME HAS A PLACE FOR IT
# - CARRY IF SMALL ENOUGH

var target_item: OGItem = null

# Targeted actions need to find a target in their is_valid method

func is_valid(query: Dictionary) -> bool:
	if target_item and ItemManager.item_is_available_to(target_item, creature):
		return true
	elif target_item: 
		target_item = null
	# action is relevant if the query relates to items in creature's owned list
	if !(query.has('creature') and query['creature'].has('owned') and query['creature']['owned'].has(HAS)):
		return false
	var items = query['creature']['owned'][HAS]
	
	for item in items:
#		var sim_item = simulate_object(item)
		var found = ItemManager.find_all_available_items_with_properties(item, ItemManager.PREFER_FAVORITE, creature)
		if !found.empty():
			target_item = found.front()
			return true
	return false

# The conditions that activate the Action
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:

	return conditions

# The outcome of the Action

func applied_transform(transform: Dictionary = {}) -> Dictionary:
	var item = simulate_object(target_item)
	transform = {
		'creature': {
			'owned': {
				ADD: [item]
			},
#			'inventory': {
#				ADD: [item]
#			}
		}
	}
	return transform

func get_cost(): return 1

func perform():
	target_item = null
	
func reset():
	target_item = null

func get_class(): return 'ActionOwnItem'
