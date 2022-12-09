extends GOAPGoal
class_name GoalHoldBone

#var actor: OGCreature setget _set_actor
#var state_tracker: GOAPStateTracker setget _set_state_tracker

func _set_actor(val):
	actor = val
	actor.connect("inventory_changed", self, "_set_has_a_bone")
	
func _set_state_tracker(val):
	state_tracker = val
	_set_has_a_bone()
	_set_bone_is_available()
	

func is_valid() -> bool:
	return true
	
func get_priority():
	return 1
	
func trigger_conditions() -> Dictionary:
	return {
		'has_a_bone': false,
		'bone_is_available': true,
	}
	
func get_desired_outcome() -> Dictionary:
	return {
		'has_a_bone': true
	}

func _init():
	ItemManager.connect("bone_availability_changed", self, "_set_bone_is_available")
#	_set_has_a_bone()
#	_set_bone_is_available()

# this is run when the orc's inventory changes to set the 'has_bone' property in state_tracker
func _set_has_a_bone():
	for item in actor.get_inventory():
		if item is OGItemBone:
			state_tracker.set_state_for('has_a_bone', true)
			return	
	state_tracker.set_state_for('has_a_bone', false)

# this is run whenever an OGItemBone is changed (created, destroyed, tagged, untagged)
# a bone is available if there is an untagged or tagged by this creature bone accessible by the creature
# how do I handle accessible checks? Say a bone is behind a wall, then the wall comes down.
# TODO: figure that out
func _set_bone_is_available():

	var available = false
	for item in actor.tagged:
		if item is OGItemBone:
			available = true
			break
	if !available:
		available = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'}) != null
	state_tracker.set_state_for('bone_is_available', available)
