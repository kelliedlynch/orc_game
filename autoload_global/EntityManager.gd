extends Node


func _entity_location_changed(entity: EntityModel, loc: Vector2, old_loc: Vector2 = Vector2(-1, -1)):
	if loc == old_loc:
		return
	var map = get_tree().current_scene.region_map
	
	if old_loc > Vector2.ZERO:
		var old_tile = map.tile_at(old_loc.x, old_loc.y)
		old_tile.entities.remove(old_tile.entities.find(entity))
	
	if loc > Vector2.ZERO:
		var new_tile = map.tile_at(loc.x, loc.y)
		new_tile.entities.append(entity)



