extends GOAPAction
class_name ActionConstructBuilt

var built: OGBuilt


func is_valid(_query: Dictionary) -> bool:
	if !built or built.is_suspended:
		return false
	return true

# The conditions that activate the Action
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {

	}
	return conditions

# The outcome of the Action
func applied_transform(transform: Dictionary = {}) -> Dictionary:
	transform = {

	}
	return transform



func perform():
	# Tag the required items
	if creature.tagged.size() == 0 && !built.is_materials_cost_paid():
		for material_name in built.required_materials:
			var found = ItemManager.find_available_item_with_properties({ 'class_name': material_name }, built.required_materials[material_name])
			if found.size() > 0:
				for item in found:
					creature.tag_item(item)
			else:
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
		for material_name in built.required_materials:
			var qty_found = built._materials_used[material_name]
			if qty_found >= built.required_materials[material_name]:
				continue
				
			if qty_found < built.required_materials[material_name]:
				for item in creature.get_inventory():
					if item.get_class() == material_name:
						built.use_item_in_construction(item)
						creature.untag_item(item)
						creature.remove_from_inventory(item)
						return false
				return false
	if !built.is_complete && built.is_materials_cost_paid():
		built.build_cost_paid += creature.build_power
		return false
	if built.is_complete:
		creature.state_tracker.set_state_for('job_completed', true)
		return true
	return false

func get_class(): return 'ActionConstructBuilt'
