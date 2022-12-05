extends EntityModel
class_name OGItemBone

func _init():
	print('init bone')
	size = 0.1
	weight = 0.1
	body.sprite.texture = load('res://item/og_item_bone.tres')
