extends "res://maps/OrcGameMap.gd"
class_name RegionMap

const RegionMapTile = preload("res://maps/regionmap/RegionMapTile.gd")

func create_tiles(world_tile: WorldMapTile):
	var elevation_noise = init_noise( int(floor(world_tile.seismic_activity * 5.0)), 10.0 + 50.0 * (1.0 - world_tile.elevation), abs(world_tile.elevation), 1.0 + 2.0 * world_tile.seismic_activity)
	var soil_quality_noise = init_noise(3, 20.0, world_tile.soil_quality, 2.0)
	for i in range(map_size.x * map_size.y):
		var x = i % map_size.x
		var y = floor(i / map_size.x)
		var tile = RegionMapTile.new(x, y)
		tile.elevation = elevation_noise.get_noise_2d(x, y)
		tile.soil_quality = apply_factor(world_tile.soil_quality, soil_quality_noise.get_noise_2d(x, y))
		if tile.soil_quality > 0.5:
			tile.tile_type = TerrainConstants.TILE_TYPE.GRASS
		else:
			tile.tile_type = TerrainConstants.TILE_TYPE.DIRT
		map_tiles.append(tile)
		Global.pathfinder.add_point(i, Vector2(x, y))
	for i in range(map_tiles.size()):
		var tile = map_tiles[i]
		var adj_tiles = tiles_adjacent_to(tile)
		for adj in adj_tiles:
			Global.pathfinder.connect_points(i, map_tiles.find(adj))
	
func draw_tile_map():
	var surface_layer = RegionMapLayer.new(tile_size)
	var vegetation_layer = RegionMapLayer.new(tile_size)
	add_child(surface_layer)
	add_child(vegetation_layer)
	for tile in map_tiles:
		var x = tile.x
		var y = tile.y
		var base_tile_type = TerrainConstants.TILE_TYPE.keys()[TerrainConstants.REGION_PARAMETERS[tile.region_type]['tile_types']['base_tile_types'][0]]
		surface_layer.set_cell(x, y, surface_layer.tile_set.find_tile_by_name(base_tile_type))
		if tile.tile_type != TerrainConstants.TILE_TYPE.DIRT:
			vegetation_layer.set_cell(x, y, vegetation_layer.tile_set.find_tile_by_name(TerrainConstants.TILE_TYPE.keys()[tile.tile_type]))
		# Add a one tile border around the map so autotile will work
		var xx = map_size.x; var yy = map_size.y
		if x == 0:
			xx = x - 1
		if x == map_size.x - 1:
			xx = x + 1
		if x != xx:
			surface_layer.set_cell(xx, y, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(xx, y, vegetation_layer.get_cell(x, y))
		if y == 0:
			yy = y - 1
		if y == map_size.x - 1:
			yy = y + 1
		if y != yy:
			surface_layer.set_cell(x, yy, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(x, yy, vegetation_layer.get_cell(x, y))
		if x != xx and y != yy:
			surface_layer.set_cell(xx, yy, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(xx, yy, vegetation_layer.get_cell(x, y))
	surface_layer.update_bitmask_region(Vector2(0, 0), Vector2(map_size.x, map_size.y))
	vegetation_layer.update_bitmask_region(Vector2(0, 0), Vector2(map_size.x, map_size.y))

func _enter_tree():
	draw_tile_map()
