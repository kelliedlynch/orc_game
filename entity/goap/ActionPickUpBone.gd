extends GOAPAction
class_name ActionPickUpBone

var _bone: OGItemBone

func get_requirements():
	return { 
		'bone_is_available': true
	}
	
func get_results():
	return {
		'has_a_bone': true
	}

func perform(actor, _delta):
	var bone = null
	for item in actor.tagged:
		if item is OGItemBone:
			bone = item
			break
	if bone:
		if ItemManager.item_is_at_location(bone, actor.location):
			ItemManager.creature_pick_up_item(actor, bone)
			bone = null
			return true
		actor.move_toward_location(bone.location)
	else:
		bone = ItemManager.find_available_item_with_properties({'class_name': 'OGItemBone'})
		if bone:
			actor.tag_item(bone)
	return false
