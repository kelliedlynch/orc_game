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

func add_to_world(item: OGItem):
	item.add_to_group(Group.Item.ALL_ITEMS)
	item.add_to_group(Group.Item.AVAILABLE_ITEMS)	

func get_items_at_location(loc: Vector2):
	var tile = map.tile_at(loc)
	return tile.get_items()
	
func item_is_at_location(item: OGItem, loc: Vector2):
	var tile = map.tile_at(loc)
	return tile.get_items().has(item)

# finds an item on the map with the given properties and returns it
func find_any_available_item_with_properties(properties: Dictionary, qty: int = 1) -> OGItem:
	# { class_name: OGItemBone }
	var found = []
	for item in get_tree().get_nodes_in_group(Group.Item.AVAILABLE_ITEMS):
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
			 _sort_condition: int = PREFER_CLOSER, creature: OGCreature = null) -> Array:
	var items = []
	if creature:
		# TODO: ALSO CHECK OWNED AND TAGGED?
		for item in get_tree().get_nodes_in_group(Group.Item.AVAILABLE_ITEMS):
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
		items = get_tree().get_nodes_in_group(Group.Item.AVAILABLE_ITEMS)
	# TODO: ADD SORT CONDITIONS
	return items

func item_is_available_to(item: OGItem, creature: OGCreature) -> bool:
	# checks that the item is not owned or tagged by another creature, and that the item is
	# reachable by this creature
	if item.tagged and creature.tagged.has(item):
		return true
	if item.owned and creature.owned.has(item):
		return true
	if (item.is_in_group(Group.Item.AVAILABLE_ITEMS)):
		return true
	return false

func creature_pick_up_item(creature: OGCreature, item: OGItem):
	if item_is_at_location(item, creature.location):
		creature.add_to_inventory(item)
		item.remove_from_map()

func creature_own_item(creature: OGCreature, item: OGItem):
	creature.own_item(item)
	if !item.is_available() and item.is_in_group(Group.Item.AVAILABLE_ITEMS):
		item.remove_from_group(Group.Item.AVAILABLE_ITEMS)
	
func creature_unown_item(creature: OGCreature, item: OGItem):
	creature.unown_item(item)
	if item.is_available() and !item.is_in_group(Group.Item.AVAILABLE_ITEMS):
		item.add_to_group(Group.Item.AVAILABLE_ITEMS)
	
func creature_tag_item(creature: OGCreature, item: OGItem):
	creature.tag_item(item)
	if !item.is_available() and item.is_in_group(Group.Item.AVAILABLE_ITEMS):
		item.remove_from_group(Group.Item.AVAILABLE_ITEMS)
		
func creature_untag_item(creature: OGCreature, item: OGItem):
	creature.untag_item(item)
	if item.is_available() and !item.is_in_group(Group.Item.AVAILABLE_ITEMS):
		item.add_to_group(Group.Item.AVAILABLE_ITEMS)
	
func item_used_in_built(item: OGItem):
	item.queue_free()

