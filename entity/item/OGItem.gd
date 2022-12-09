extends OGEntity
class_name OGItem

var tagged: bool = false setget _set_tagged

func _set_tagged(val):
	tagged = val
	if tagged:
		remove_from_group('untagged_items')
		add_to_group('tagged_items')
	else:
		remove_from_group('tagged_items')
		add_to_group('untagged_items')
	emit_signal('availability_changed', self)
signal availability_changed()

func _ready():
	add_to_group('items')
	add_to_group('untagged_items')
	connect("location_changed", ItemManager, "_location_changed")
	connect('availability_changed', ItemManager, 'item_availability_changed')
	emit_signal("availability_changed", self)
	
#func was_claimed_by(creature: CreatureModel):
#	print('item was claimed')
#	claimed_by = creature
#	remove_from_group('unclaimed_items')
#
#func was_unclaimed():
#	print('item was unclaimed')
#	claimed_by = null
#	add_to_group('unclaimed items')
