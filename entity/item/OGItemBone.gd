extends ItemModel
class_name OGItemBone

var item_name: String

func _init():
	size = 0.1
	weight = 0.1
	item_name = 'Bone'
	
	
func _ready():
	body.sprite.texture = load('res://entity/item/og_item_bone.tres')
