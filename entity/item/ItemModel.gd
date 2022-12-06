extends EntityModel
class_name ItemModel

var claimed_by: CreatureModel = null

func _ready():
	add_to_group('items')
	add_to_group('unclaimed_items')
	
func was_claimed_by(creature: CreatureModel):
	print('item was claimed')
	claimed_by = creature
	remove_from_group('unclaimed_items')

func was_unclaimed():
	print('item was unclaimed')
	claimed_by = null
	add_to_group('unclaimed items')
