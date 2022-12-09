extends EntityManager

	
func get_items_on_tile(tile):
	return tile.get_items()

func get_items_at_location(loc):
	var tile = map.tile_at(loc)
	return get_items_on_tile(tile)
	
func item_is_at_location(item, loc):
	var tile = map.tile_at(loc)
	return get_items_on_tile(tile).has(item)

# finds an item on the map with the given properties and returns it
func find_available_item_with_properties(properties: Dictionary) -> OGItem:
	# { class_name: OGItemBone }
	for item in get_tree().get_nodes_in_group('untagged_items'):
		var item_is_match = false
		for property_name in properties:
			var property_value = item.get_class() if property_name == 'class_name' else item.get(property_name)
			if property_value == properties[property_name]:
				item_is_match = true
			else:
				item_is_match = false
				break
		if item_is_match:
			return item
	return null

func creature_pick_up_item(creature, item):
	if item_is_at_location(item, creature.location):
		creature.add_to_inventory(item)
		remove_item_from_location(item, creature.location)
		
func remove_item_from_location(item, loc):
	if item_is_at_location(item, loc):
		var tile = map.tile_at(loc)
		tile.remove_entity_from_tile(item)
		item.sprite.queue_free()

func item_availability_changed(item):
	if item is OGItemBone:
		emit_signal("bone_availability_changed")
signal bone_availability_changed()

func creature_tagged_item(creature, item, is_tagged):
	pass

#func _bone_availability_changed():
#	emit_signal("bone_availability_changed")
