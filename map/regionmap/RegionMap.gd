extends OrcGameMap
class_name RegionMap

onready var surface_layer: RegionMapLayer = $SurfaceLayer
onready var vegetation_layer: RegionMapLayer = $VegetationLayer

signal region_tiles_generated()

func _ready():
	var error_code = connect("region_tiles_generated", self, 'draw_tile_map')
	if error_code != 0: push_error('ERROR: %d' % error_code)

func create_tiles(world_tile: OrcGameMapTile):
	var elevation_noise = init_noise( int(floor(world_tile.terrain_intensity * 5.0)), 10.0 + 50.0 * (1.0 - world_tile.elevation), abs(world_tile.elevation), 1.0 + 2.0 * world_tile.terrain_intensity)
	var soil_quality_noise = init_noise(3, 20.0, world_tile.soil_quality, 2.0)
	for i in range(width * height):
		var x = i % width
		#warning-ignore:integer_division
		var y = i / width
		var tile = RegionMapTile.new(x, y)
		tile.elevation = elevation_noise.get_noise_2d(x, y)
		tile.soil_quality = apply_factor(world_tile.soil_quality, soil_quality_noise.get_noise_2d(x, y))
		if tile.soil_quality > 0.5:
			tile.tile_type = TileType.Type.TILE_GRASS
		else:
			tile.tile_type = TileType.Type.TILE_DIRT
		map_tiles.append(tile)
		Global.pathfinder.add_point(i, Vector2(x, y))
	for i in range(map_tiles.size()):
		var tile = map_tiles[i]
		var adj_tiles = tiles_adjacent_to(tile)
		for adj in adj_tiles:
			Global.pathfinder.connect_points(i, map_tiles.find(adj))
	emit_signal("region_tiles_generated")
	
func draw_tile_map():
	var WorldgenParameters = load('res://map/worldmap/WorldgenParameters.gd')
	for tile in map_tiles:
		var x = tile.x
		var y = tile.y
		var base_tile_type = WorldgenParameters.RegionParameters[tile.region_type]['tile_types']['base_tile_types'][0]
		surface_layer.set_cell(x, y, surface_layer.tile_set.find_tile_by_name(TileType.Type.keys()[base_tile_type]))
		if tile.tile_type != TileType.Type.TILE_DIRT:
			vegetation_layer.set_cell(x, y, vegetation_layer.tile_set.find_tile_by_name(TileType.Type.keys()[tile.tile_type]))
		# Add a one tile border around the map so autotile will work
		var xx = width; var yy = height
		if x == 0:
			xx = x - 1
		if x == width - 1:
			xx = x + 1
		if x != xx:
			surface_layer.set_cell(xx, y, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(xx, y, vegetation_layer.get_cell(x, y))
		if y == 0:
			yy = y - 1
		if y == width - 1:
			yy = y + 1
		if y != yy:
			surface_layer.set_cell(x, yy, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(x, yy, vegetation_layer.get_cell(x, y))
		if x != xx and y != yy:
			surface_layer.set_cell(xx, yy, surface_layer.get_cell(x, y))
			vegetation_layer.set_cell(xx, yy, vegetation_layer.get_cell(x, y))
	surface_layer.update_bitmask_region(Vector2(0, 0), Vector2(width, height))
	vegetation_layer.update_bitmask_region(Vector2(0, 0), Vector2(width, height))
