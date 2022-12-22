extends GOAPGoal
class_name GoalClaimBone



func _ready():
	ItemManager.connect("item_availability_changed", self, "_set_bone_is_available")

# Things that must be true for this goal to be considered
func requirements(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		OR: {
			'world': {
				'unowned_items': {
					HAS: {
						'material': Item.Material.BONE
					}
				}
			},
			'creature': {
				'owned': {
					HAS: {
						'material': Item.Material.BONE
					}
				}
			}
		}
	}
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			NOT: {
				OR: {
					'owned': {
						HAS: [
							{
								'material': Item.Material.BONE
							}
						]
					},
					'inventory': {
						HAS: [
							{
								'material': Item.Material.BONE
							}
						]
					}
					
				}
			}
		}
	}
	return conditions

# The desired outcome of the goal
func desired_state(query: Dictionary = {}) -> Dictionary:
	query = {
		'creature': {
			'owned': {
				HAS: [
					{
						'material': Item.Material.BONE
					}
				]
			},
			'inventory': {
				HAS: [
					{
						'material': Item.Material.BONE
					}
				]
			}
		}
	}
	return query
	
func get_priority():
	return Goal.PRIORITY_WANT
	

	
	
	
	
	
	
	
	
func assign_to_creature(creature: OGCreature):
	.assign_to_creature(creature)
#	creature.connect("inventory_changed", self, "_set_carries_a_bone")
#	creature.connect("creature_owned_item", self, "_set_owns_a_bone")
#	_set_carries_a_bone(creature)
#	var owned = false
#	for item in creature.owned:
#		if item is OGItemBone:
#			owned = true
#			break
#	creature.state_tracker.set_state_for('owns_a_bone', owned)
#	var found = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
#	creature.state_tracker.set_state_for('bone_is_available', found.size() > 0)
#
## this is run when the orc's inventory changes to set the 'carries_a_bone' property in state_tracker
#func _set_carries_a_bone(_creature: OGCreature):
#	for item in creature.get_inventory():
#		if item is OGItemBone:
#			creature.state_tracker.set_state_for('carries_a_bone', true)
#			return	
#	creature.state_tracker.set_state_for('carries_a_bone', false)
#
## This is run when the creature's owned items changes to set 'owns_a_bone'
#func _set_owns_a_bone(_creature: OGCreature, item: OGItem, owned: bool):
#	if item is OGItemBone:
#		creature.state_tracker.set_state_for('owns_a_bone', owned)
#
## this is run whenever an OGItemBone is changed (created, destroyed, tagged, untagged)
## a bone is available if there is an untagged or tagged by this creature bone accessible by the creature
## how do I handle accessible checks? Say a bone is behind a wall, then the wall comes down.
## TODO: figure that out
#func _set_bone_is_available(changed: OGItem):
#	if !(changed is OGItemBone):
#		return
#	var bone 
#	for item in creature.tagged:
#		if item is OGItemBone:
#			bone = true
#	var found = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
#	if !bone: bone = found.size() > 0
#	creature.state_tracker.set_state_for('bone_is_available', bone)

func get_class(): return 'GoalClaimBone'
