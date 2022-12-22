extends EntityManager

# Flags for item searches
enum {
	PREFER_CLOSER,
	# lower value
	PREFER_CHEAPER,
	# items in stockpiles
	PREFER_STORED,
	PREFER_FAVORITE,
}

	
func get_items_on_tile(tile: OrcGameMapTile):
	return tile.get_items()

func get_items_at_location(loc: Vector2):
	var tile = map.tile_at(loc)
	return get_items_on_tile(tile)
	
func item_is_at_location(item: OGItem, loc: Vector2):
	var tile = map.tile_at(loc)
	return get_items_on_tile(tile).has(item)

# finds an item on the map with the given properties and returns it
func find_any_available_item_with_properties(properties: Dictionary, qty: int = 1) -> OGItem:
	# { class_name: OGItemBone }
	var found = []
	for item in get_tree().get_nodes_in_group(Group.Item.UNOWNED_ITEMS):
		if item.is_in_group(Group.Item.TAGGED_ITEMS) || item.is_in_group(Group.Item.USED_IN_BUILT):
			continue
		var item_is_match = false
		for property_name in properties:
			var property_value = item.get_class() if property_name == 'class_name' else item.get(property_name)
			if property_value == properties[property_name]:
				item_is_match = true
			else:
				item_is_match = false
				break
		if item_is_match:
			found.append(item)
			if found.size() >= qty:
				return found
	return found

func find_all_available_items_with_properties(properties: Dictionary,\
			 sort_condition: int = PREFER_CLOSER, creature: OGCreature = null) -> Array:
	var items = []
	# TODO: ACTUALLY LOOK AT THE PROPERTIES
	if creature:
		for item in get_tree().get_nodes_in_group(Group.Item.ALL_ITEMS):
			for property in properties:
				var prop = properties[property]
				var found
				if prop is Array:
					var matches = _eval_operator_query(prop.front(), item.get(property), prop.back())
					if matches: found = item
				else:
					if property == QUANTITY:
						continue
					if item[property] == properties[property]:
						found = item
				if found and item_is_available_to(found, creature):
					items.append(found)
	else:
		for item in get_tree().get_nodes_in_group(Group.Item.UNOWNED_ITEMS):
			if item.is_in_group(Group.Item.TAGGED_ITEMS) || item.is_in_group(Group.Item.USED_IN_BUILT):
				continue
			else:
				items.append(item)
	# TODO: ADD SORT CONDITIONS
	return items

#func find_closest_available_item_with_properties(properties: Dictionary, qty: int = 1):
#	pass
#
#func find_most_preferred_item_with_properties(properties: Dictionary):
#	pass

func item_is_available_to(item: OGItem, creature: OGCreature) -> bool:
	# checks that the item is not owned or tagged by another creature, and that the item is
	# reachable by this creature
	if item.tagged and !creature.tagged.has(item):
		return false
	if item.owned and !creature.owned.has(item):
		return false
	if (item.is_in_group(Group.Item.UNTAGGED_ITEMS) or creature.tagged.has(item)) \
			and (item.is_in_group(Group.Item.UNOWNED_ITEMS) or creature.owned.has(item)) \
			and (!item.is_in_group(Group.Item.USED_IN_BUILT) or creature.tagged.has(item)):
		return true
	return false

func creature_pick_up_item(creature: OGCreature, item: OGItem):
	if item_is_at_location(item, creature.location):
#		remove_item_from_location(item, creature.location)
		creature.add_to_inventory(item)
		item.sprite.queue_free()
#		creature.connect('location_changed', item, '_')
		item.set_location(Global.OFF_MAP)
		
#func creature_own_item(creature: OGCreature, item: OGItem):
#	creature.own_item(item)
#	pass
		
#func remove_item_from_location(item: OGItem, loc: Vector2):
#	if item_is_at_location(item, loc):
##		var tile = map.tile_at(loc)
##		tile.remove_entity_from_tile(item)
#		item.sprite.queue_free()

func item_availability_changed(item: OGItem):
	emit_signal('item_availability_changed', item)
signal item_availability_changed()
