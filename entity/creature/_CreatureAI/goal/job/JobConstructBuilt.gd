extends Job
class_name JobConstructBuilt
#
#var built: OGBuilt
#
#
#func _init(_built: OGBuilt):
#	built = _built
#	required_skill = CreatureSkill.BUILDING
#
#func assign_to_creature(creature: OGCreature):
#	.assign_to_creature(creature)
#	ItemManager.connect('item_availability_changed', self, '_set_job_materials_available')
#	built.connect('completed_changed', self, '_set_job_completed')
#	actor.state_tracker.set_state_for('job_materials_available', _materials_are_available())
#	_set_job_completed(built)
#	for action in actor.state_tracker.actions:
#		if action is ActionConstructBuilt:
#			action.built = built
#
#func unassign():
#	ItemManager.disconnect('item_availability_changed', self, '_set_job_materials_availabe')
#	built.disconnect('completed_changed', self, '_set_job_completed')
#	actor.state_tracker.stop_tracking_state('job_materials_available')
#	for action in actor.state_tracker.actions:
#		if action is ActionConstructBuilt:
#			action.built = null
#	.unassign()
#
#func is_valid() -> bool:
#	if built.is_paused || !_materials_are_available():
#		return false
#	return true
#
##func trigger_conditions() -> Dictionary:
##	return {
##		'job_materials_available': true
##	}
##
##func get_desired_outcome() -> Dictionary:
##	return {
##		'job_completed': true
##	}
#
#func _materials_are_available() -> bool:
#	for material_name in built.required_materials:
#		var qty_found = built._materials_used[material_name]
#		var qty_required = built.required_materials[material_name]
#		if qty_found >= qty_required:
#			continue
##
##		for item_name in built._materials_used:
##			if item_name == material_name:
##				qty_found += 1
##				if qty_found >= qty_required:
##					break
#		for item in actor.tagged:
#			if item.get_class() == material_name:
#				qty_found += 1
#				if qty_found >= qty_required:
#					break
#		if qty_found < qty_required:
#			var found = ItemManager.find_available_item_with_properties( { 'class_name': material_name } )
#			var in_world = found.size()
#			qty_found += in_world
#		if qty_found < qty_required:
#			return false
#	return true
#
#func _set_job_materials_available(item: OGItem):
#	if !built.required_materials.keys().has(item.get_class()):
#		return
#	actor.state_tracker.set_state_for('job_materials_available', _materials_are_available())
#
#func _set_job_completed(_built):
#	actor.state_tracker.set_state_for('job_completed', built.is_complete)
#	if built.is_complete:
#		var index = actor.state_tracker.goals.find(self)
#		actor.state_tracker.goals.remove(index)
#		JobDispatch._on_job_completed(self)
#
#
## Remove this job's states from the tracker. Only remove ones that are specific to this Job
#func tree_exiting():
#	actor.state_tracker.stop_tracking_state('job_materials_available')
#	actor.state_tracker.stop_tracking_state('job_completed')
#	for action in actor.state_tracker.actions:
#		if action is ActionConstructBuilt:
#			action.built = null
#
func get_class(): return 'JobConstructBuilt'
