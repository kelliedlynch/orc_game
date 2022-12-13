extends GOAPAction
class_name ActionClaimBone

var _bone: OGItemBone

func get_requirements():
	return { 
		'bone_is_available': true
	}
	
func get_results():
	return {
		'owns_a_bone': true,
		'carries_a_bone': true,
	}

func perform(actor: OGCreature):
	var bone = null
	for item in actor.tagged:
		if item is OGItemBone:
			bone = item
			break
	if bone:
		if ItemManager.item_is_at_location(bone, actor.location):
			ItemManager.creature_pick_up_item(actor, bone)
#			ItemManager.creature_claim_item(actor, bone)
			actor.own_item(bone)
			actor.untag_item(bone)
			bone = null
			return true
		actor.move_toward_location(bone.location)
	else:
		bone = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
		if bone.size() > 0:
			actor.tag_item(bone[0])
	return false

func get_class(): return 'ActionClaimBone'
