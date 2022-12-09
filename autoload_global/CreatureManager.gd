extends EntityManager

func creature_created(creature):
	creature.add_to_group('creatures')
	
func get_creatures_on_tile(tile):
	return tile.get_creatures()

func get_creatures_at_location(loc):
	var tile = map.tile_at(loc)
	return get_creatures_on_tile(tile)
	
func creature_is_at_location(creature, loc):
	var tile = map.tile_at(loc)
	return get_creatures_on_tile(tile).has(creature)
