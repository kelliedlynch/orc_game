extends GOAPAction
class_name ActionPickUpItem

var target_item: OGItem

# Targeted actions need to find a target in their is_valid method

func is_valid(query: Dictionary) -> bool:
	# action is relevant if creature wants an item in inventory
	if !(query.has('creature') and query['creature'].has('inventory') and query['creature']['inventory'].has(HAS)):
		return false
		
	var items = query['creature']['inventory'][HAS]
	for item in items:
#		var sim_item = simulate_object(item)
		var found = ItemManager.find_all_available_items_with_properties(item, ItemManager.PREFER_FAVORITE, creature)
		if !found.empty():
			target_item = found.front()
			return true
	target_item = null
	return false

# The conditions that activate the Action
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:

	return conditions

# The outcome of the Action

func applied_transform(transform: Dictionary = {}) -> Dictionary:
	var sim = simulate_object(target_item)
	transform = {
		'creature': {
			'inventory': {
				ADD: [sim]
			}
		}
	}
	return transform

func get_cost():
	return 1
	
func reset():
	target_item = null

func perform():
	if creature.location != target_item.location:
		creature.move_toward_location(target_item.location)
		return false
	ItemManager.creature_pick_up_item(creature, target_item)
	target_item = null
	return true

func get_class(): return 'ActionPickUpItem'
