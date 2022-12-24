extends OGItem
class_name OGItemMeat

func _init():
	size = 0.1
	weight = 0.1
	entity_name = 'Meat'
	material = Item.Material.MEAT
	edible = true
	nutrition_value = 60
	value = 1
	instance_name = entity_name

func get_class(): return 'OGItemMeat'
