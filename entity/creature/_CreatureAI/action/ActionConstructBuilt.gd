extends GOAPAction
class_name ActionConstructBuilt

var built: OGBuilt

func get_requirements():
	return { 
		'job_materials_available': true
	}
	
func get_results():
	return {
		'job_completed': true
	}

func perform(actor: OGCreature):
	# Tag the required items
	if actor.tagged.size() == 0 && !built.is_materials_cost_paid():
		for material_name in built.required_materials:
			var found = ItemManager.find_available_item_with_properties({ 'class_name': material_name }, built.required_materials[material_name])
			if found.size() > 0:
				for item in found:
					actor.tag_item(item)
			else:
				return false
		return false
		
	# Gather up the tagged items
	if actor.tagged.size() > 0 && !built.is_materials_cost_paid():
		for item in actor.tagged:
			if actor.get_inventory().has(item):
				continue
			else:
				if actor.location == item.location:
					ItemManager.creature_pick_up_item(actor, item)
					return false
				actor.move_toward_location(item.location)
				return false

	if actor.location != built.location:
		actor.move_toward_location(built.location)
		return false
			
	# Tagged items are gathered; build the Built
	if !built.is_complete && !built.is_materials_cost_paid():
		# Put tagged items into the Built skeleton
		for material_name in built.required_materials:
			var qty_found = built._materials_used[material_name]
			if qty_found >= built.required_materials[material_name]:
				continue
				
			if qty_found < built.required_materials[material_name]:
				for item in actor.get_inventory():
					if item.get_class() == material_name:
						built.use_item_in_construction(item)
						actor.untag_item(item)
						actor.remove_from_inventory(item)
						return false
				return false
	if !built.is_complete && built.is_materials_cost_paid():
		built.build_cost_paid += actor.build_power
		return false
	if built.is_complete:
		actor.state_tracker.set_state_for('job_completed', true)
		return true
	return false

func get_class(): return 'ActionConstructBuilt'
