extends GOAPQueryable
#class_name EntityManager

var map: RegionMap

func _location_changed(entity: OGEntity, loc: Vector2, old_loc: Vector2 = Vector2(-1, -1)):
	if loc == old_loc or !map:
		return

	if old_loc >= Vector2.ZERO:
		var old_tile: RegionMapTile = map.tile_at(old_loc)
		old_tile.remove_entity_from_tile(entity)
	
	if loc >= Vector2.ZERO:
		var new_tile: RegionMapTile = map.tile_at(loc)
		new_tile.add_entity_to_tile(entity)

func get_class(): return 'EntityManager'
