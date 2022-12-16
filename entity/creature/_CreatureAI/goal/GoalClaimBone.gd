extends GOAPGoal
class_name GoalClaimBone


func _ready():
	ItemManager.connect("item_availability_changed", self, "_set_bone_is_available")

func requirements(conditions: Array = []) -> Array:
	var all_conditions = conditions.duplicate()
	all_conditions.append_array([
		OR,
			{ 'creature.owned': [ HAS, { 'material': Item.Material.BONE } ] },
			{ 'item.is_available_with_properties' : [ HAS, { 'material': Item.Material.BONE } ] },
	])
	return .goal_is_possible(all_conditions)
	
func get_priority():
	return Goal.PRIORITY_WANT
	
func trigger_conditions(conditions: Array = []) -> Array:
	var all_conditions = conditions.duplicate()
	all_conditions.append_array([
		AND,
			{ 'creature.inventory': [ 
				NOT,
					[ HAS, { 'material': Item.Material.BONE } ]
				]
			}
	])
	return .trigger_conditions(all_conditions)
	
func end_state(conditions: Array = []) -> Array:
	var all_conditions = conditions.duplicate()
	all_conditions.append_array([
		AND,
			{ 'creature.owned': [ HAS, { 'material': Item.Material.BONE } ] },
			{ 'creature.inventory': [ HAS, { 'material': Item.Material.BONE } ] },
	])
	return .end_state(all_conditions)
	
	
	
	
	
	
	
	
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
