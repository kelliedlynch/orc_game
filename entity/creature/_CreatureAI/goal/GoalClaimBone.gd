extends GOAPGoal
class_name GoalClaimBone

# TODO: FIX CYCLIC DEPENDENCIES WITH CREATURES

func _ready():
	ItemManager.connect("item_availability_changed", self, "_set_bone_is_available")

func is_valid() -> bool:
	return true
	
func get_priority():
	return Goal.PRIORITY_WANT
	
func trigger_conditions() -> Dictionary:
	return {
		'owns_a_bone': false,
		'bone_is_available': true,
	}
	
func get_desired_outcome() -> Dictionary:
	return {
		'carries_a_bone': true,
		'owns_a_bone': true,
	}
	
func assign_to_creature(creature: OGCreature):
	.assign_to_creature(creature)
	creature.connect("inventory_changed", self, "_set_carries_a_bone")
	creature.connect("creature_owned_item", self, "_set_owns_a_bone")
	_set_carries_a_bone(actor)
	var owned = false
	for item in actor.owned:
		if item is OGItemBone:
			owned = true
			break
	actor.state_tracker.set_state_for('owns_a_bone', owned)
	var found = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
	creature.state_tracker.set_state_for('bone_is_available', found.size() > 0)

# this is run when the orc's inventory changes to set the 'carries_a_bone' property in state_tracker
func _set_carries_a_bone(_creature: OGCreature):
	for item in actor.get_inventory():
		if item is OGItemBone:
			actor.state_tracker.set_state_for('carries_a_bone', true)
			return	
	actor.state_tracker.set_state_for('carries_a_bone', false)
	
# This is run when the creature's owned items changes to set 'owns_a_bone'
func _set_owns_a_bone(_creature: OGCreature, item: OGItem, owned: bool):
	if item is OGItemBone:
		actor.state_tracker.set_state_for('owns_a_bone', owned)

# this is run whenever an OGItemBone is changed (created, destroyed, tagged, untagged)
# a bone is available if there is an untagged or tagged by this creature bone accessible by the creature
# how do I handle accessible checks? Say a bone is behind a wall, then the wall comes down.
# TODO: figure that out
func _set_bone_is_available(changed: OGItem):
	if !(changed is OGItemBone):
		return
	var bone 
	for item in actor.tagged:
		if item is OGItemBone:
			bone = true
	var found = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
	if !bone: bone = found.size() > 0
	actor.state_tracker.set_state_for('bone_is_available', bone)

func get_class(): return 'GoalClaimBone'
