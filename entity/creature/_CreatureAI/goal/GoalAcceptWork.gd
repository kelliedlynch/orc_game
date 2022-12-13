extends GOAPGoal
class_name GoalAcceptWork

var current_job

func _ready():
	JobDispatch.connect("worker_requested", self, "_set_bone_is_available")

func is_valid() -> bool:
	return !current_job
	
func get_priority():
	return Goal.PRIORITY_WORK
	
func trigger_conditions() -> Dictionary:
	return {
		'worker_requested': true,
	}
	
func get_desired_outcome() -> Dictionary:
	return {
		'has_a_bone': true
	}
	
func assign_to_creature(creature: OGCreature):
	creature.connect("inventory_changed", self, "_set_has_a_bone")
	creature.add_to_group(Group.Creature.LOOKING_FOR_BONE)
	_set_has_a_bone(creature)
	creature.state_tracker.set_state_for('bone_is_available', ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'}) != null)

# this is run when the orc's inventory changes to set the 'has_bone' property in state_tracker
func _set_has_a_bone(actor):
	for item in actor.get_inventory():
		if item is OGItemBone:
			actor.state_tracker.set_state_for('has_a_bone', true)
			actor.remove_from_group(Group.Creature.LOOKING_FOR_BONE)
			return	
	actor.state_tracker.set_state_for('has_a_bone', false)
	actor.add_to_group(Group.Creature.LOOKING_FOR_BONE)

# this is run whenever an OGItemBone is changed (created, destroyed, tagged, untagged)
# a bone is available if there is an untagged or tagged by this creature bone accessible by the creature
# how do I handle accessible checks? Say a bone is behind a wall, then the wall comes down.
# TODO: figure that out
func _set_bone_is_available():
	for creature in get_tree().get_nodes_in_group('looking_for_bone'):
		var available
		for item in creature.tagged:
			if item is OGItemBone:
				available = true
		if !available:
			available = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'}) != null
		creature.state_tracker.set_state_for('bone_is_available', available)
