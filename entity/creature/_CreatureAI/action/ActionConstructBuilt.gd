extends GOAPAction
class_name ActionConstructBuilt

var built: OGBuilt


func is_valid(_query: Dictionary) -> bool:
	if creature.current_goal is JobConstructBuilt:
		if !creature.current_goal.built.is_suspended:
			built = creature.current_goal.built
			return true
	built = null
	return false

# The conditions that activate the Action
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {

	}
	return conditions

# The outcome of the Action
func applied_transform(transform: Dictionary = {}) -> Dictionary:
	transform = {
		ADD: {
			'job': {
				'built': {
					'is_complete': true
				}
			}
		}
	}
	return transform



func perform():
	# Tag the required items
	if creature.tagged.size() == 0 && !built.is_materials_cost_paid():
		for material in built.materials_required:
			var qty = material[QUANTITY] if QUANTITY in material else 1
			var found = ItemManager.find_all_available_items_with_properties(material)
			if found.size() < qty:
				return false
			for item in found:
				ItemManager.creature_tag_item(creature, item)
				qty -= 1
				if qty <= 0: break
			if qty > 0:
				return false
		return false
		
	# Gather up the tagged items
	if creature.tagged.size() > 0 && !built.is_materials_cost_paid():
		for item in creature.tagged:
			if creature.get_inventory().has(item):
				continue
			else:
				if creature.location == item.location:
					ItemManager.creature_pick_up_item(creature, item)
					return false
				creature.move_toward_location(item.location)
				return false

	if creature.location != built.location:
		creature.move_toward_location(built.location)
		return false
			
	# Tagged items are gathered; build the Built
	if !built.is_complete && !built.is_materials_cost_paid():
		# Put tagged items into the Built skeleton
		if !creature.tagged.empty():
			var mat = creature.tagged.back()
			for remaining in built._required_materials_remaining:
				var props_match = true
				for prop_name in remaining:
					if prop_name == QUANTITY: continue
					if !(prop_name in mat):
						props_match = false
						break
				if props_match:
					built.use_item_in_construction(mat)
					return false
			return false
						
	if !built.is_complete && built._required_materials_remaining.empty():
		built.build_cost_paid += creature.build_power
		return false
	if built.is_complete:
		return true
	return false

func get_class(): return 'ActionConstructBuilt'
