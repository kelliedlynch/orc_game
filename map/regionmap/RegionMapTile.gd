extends OrcGameMapTile
class_name RegionMapTile

var tile_type: int


var _creatures: Array = [] setget _set_creatures, get_creatures
var _items: Array = [] setget _set_items, get_items
var _builts: Array = [] setget _set_builts, get_builts

func _set_creatures(val: Array):
	_creatures = val
func get_creatures() -> Array:
	return _creatures

func _set_items(val):
	_items = val
func get_items() -> Array:
	return _items
	
func _set_builts(val):
	_builts = val
func get_builts():
	return _builts

#signal did_add_creature_to_tile()
func _get_entity_category(entity: OGEntity) -> Array:
	if entity is OGCreature:
		return _creatures
	elif entity is OGItem:
		return _items
	elif entity is OGBuilt:
		return _builts
	else:
		return []
	
	
func add_entity_to_tile(entity: OGEntity):
	var category = _get_entity_category(entity)
	if category.has(entity):
		push_error("Failed to add entity to tile: entity already here")
		return
	category.append(entity)
	
func remove_entity_from_tile(entity: OGEntity):
	var cat = _get_entity_category(entity)
	if !cat.has(entity):
		push_error("Failed to remove entity from tile: entity %s is not here" % entity.get_class())
		return
	cat.erase(entity)

func _init(x: int, y: int).(x, y):
#	connect("did_add_creature_to_tile", CreatureManager, "_did_add_creature_to_tile")
	pass

#NOTE: trying to make sure the editor knows this returns a RegionMapTile if querying
# a region. Probably not doing it right.
func tile_at(loc: Vector2) -> RegionMapTile:
	return .tile_at(loc)
