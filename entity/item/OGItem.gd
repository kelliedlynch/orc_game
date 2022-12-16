extends OGEntity
class_name OGItem

var material: int
# TODO: FIGURE OUT HOW VALUE IS MEASURED
var value: int

var tagged: bool = false setget _set_tagged
var owned: bool = false setget _set_owned

func _set_tagged(val):
	tagged = val
	if tagged:
		remove_from_group(Group.Item.UNTAGGED_ITEMS)
		add_to_group(Group.Item.TAGGED_ITEMS)
	else:
		remove_from_group(Group.Item.TAGGED_ITEMS)
		add_to_group(Group.Item.UNTAGGED_ITEMS)
	emit_signal('availability_changed', self)
signal availability_changed()

func _set_owned(val):
	owned = val
	if owned:
		remove_from_group(Group.Item.UNOWNED_ITEMS)
		add_to_group(Group.Item.OWNED_ITEMS)
	else:
		remove_from_group(Group.Item.OWNED_ITEMS)
		add_to_group(Group.Item.UNOWNED_ITEMS)
	emit_signal('availability_changed', self)

func _ready():
	add_to_group('items')
	add_to_group(Group.Item.UNTAGGED_ITEMS)
	add_to_group(Group.Item.UNOWNED_ITEMS)
#	connect("location_changed", ItemManager, "_location_changed")
	connect('availability_changed', ItemManager, 'item_availability_changed')
	emit_signal("availability_changed", self)

func is_available() -> bool:
	return !tagged

func get_class(): return 'OGItem'
