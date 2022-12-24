extends OGItem
class_name OGItemLog

func _init():
	size = 0.3
	weight = 0.3
	entity_name = 'Log'
	material = Item.Material.WOOD
	value = 1
	instance_name = entity_name

func get_class(): return 'OGItemLog'
