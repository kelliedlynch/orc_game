extends OGItem
class_name OGItemBone

var item_name: String

func _init():
	size = 0.1
	weight = 0.1
	item_name = 'Bone'
	name = 'Bone'

#func _ready():
##	connect('availability_changed', ItemManager, '_bone_availability_changed')
#	emit_signal("item_availability_changed")

#signal item_availability_changed()

func get_class(): return 'OGItemBone'
