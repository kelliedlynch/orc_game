extends Node

func entity_location_changed(entity: OGEntity, loc: Vector2, _old_loc: Vector2 = Vector2.ZERO):
	entity.sprite.position = location_to_position(loc)
	
# "location" always refers to the map tile integer coordinate system, while "position" means the 
# viewport's coordinate system
func position_to_location(position: Vector2) -> Vector2:
	var viewport_size = get_viewport().size
	var posx = max(min(position.x, viewport_size.x), 0)
	var posy = max(min(position.y, viewport_size.y), 0)
	var x = floor(posx / Global.tile_size.x)
	var y = floor(posy / Global.tile_size.y)
	return Vector2(x, y)

func location_to_position(location: Vector2) -> Vector2:
	return location * Global.tile_size
