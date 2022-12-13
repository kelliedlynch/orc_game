extends OGItem
class_name OGItemBone

func _init():
	size = 0.1
	weight = 0.1
	entity_name = 'Bone'
	instance_name = entity_name

func get_class(): return 'OGItemBone'
