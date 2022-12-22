extends OGItem
class_name OGItemSandwich

func _init():
	size = 0.1
	weight = 0.1
	entity_name = 'Sandwich'
	material = Item.Material.WOOD
	edible = true
	nutrition_value = 60
	value = 1
	instance_name = entity_name

func get_class(): return 'OGItemSandwich'
