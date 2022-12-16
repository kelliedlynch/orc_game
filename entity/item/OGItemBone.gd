extends OGItem
class_name OGItemBone

func _init():
	size = 0.1
	weight = 0.1
	entity_name = 'Bone'
	material = Item.Material.BONE
	value = 1
	instance_name = entity_name

func get_class(): return 'OGItemBone'
