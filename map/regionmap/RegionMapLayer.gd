extends OrcGameMapLayer
class_name RegionMapLayer

#const RegionMapTile = preload("res://maps/regionmap/RegionMapTile.gd")

#func _init():
#	set_tileset(load('res://terrain/terrain_tiles.tres'))

#func _unhandled_input(event):
#	if event is InputEventMouseButton and event.is_pressed():
#		var target_location = viewport_to_map(event.position)
#		var tile = tile_at(target_location.x, target_location.y)
#		JobDispatch.new_job(tile.location.x, tile.location.y)