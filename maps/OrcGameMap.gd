extends Node2D
class_name OrcGameMap

const TerrainConstants = preload('res://maps/TerrainConstants.gd')
# Map dimensions, generate these another way later
var map_size: Dictionary = { 'x': 64, 'y': 37}
#var map_layers: Array
var tile_size: Vector2 = Vector2(16.0, 16.0)
# Array of MapTile objects, which contain terrain data, but not graphical data
# or maybe grapical data for every layer?
var map_tiles: Array


func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise

func tile_at(x: int, y: int) -> OrcGameMapTile:
	if x > map_size.x:
		push_error("Coord x:" + str(x) + " out of bounds")
		return null
	if y > map_size.y:
		push_error("Coord y:" + str(y) + " out of bounds")
		return null
	var index = y * map_size.x + x
	return map_tiles[index]

#func tile_at_viewport_position(position: Vector2):
#	var grid_loc = viewport_to_grid(position)
#	return tile_at(grid_loc.x, grid_loc.y)

func tiles_adjacent_to(tile: OrcGameMapTile) -> Array:
	var tiles = []
	if tile.x > 0:
		tiles.append(tile_at(tile.x - 1, tile.y))
		if tile.y > 0:
			tiles.append(tile_at(tile.x - 1, tile.y - 1))
		if tile.y < map_size.y - 1:
			tiles.append(tile_at(tile.x - 1, tile.y + 1))	
	if tile.y > 0:
		tiles.append(tile_at(tile.x, tile.y - 1))
	if tile.y < map_size.y - 1:
		tiles.append(tile_at(tile.x, tile.y + 1))
	if tile.x < map_size.x - 1:
		tiles.append(tile_at(tile.x + 1, tile.y))
		if tile.y > 0:
			tiles.append(tile_at(tile.x + 1, tile.y - 1))
		if tile.y < map_size.y - 1:
			tiles.append(tile_at(tile.x + 1, tile.y + 1))
	return tiles

func tiles_orthogonal_to(tile: OrcGameMapTile) -> Array:
	var tiles = []
	if tile.x > 0:
		tiles.append(tile_at(tile.x - 1, tile.y))
	if tile.x < map_size.x - 1:
		tiles.append(tile_at(tile.x + 1, tile.y))
	if tile.y > 0:
		tiles.append(tile_at(tile.x, tile.y - 1))
	if tile.y < map_size.y - 1:
		tiles.append(tile_at(tile.x, tile.y + 1))
	return tiles
	
#func draw_rect_map():
#	for tile in map_tiles:
#		var position = map_to_world(Vector2(tile.x, tile.y))
#		var rect = ColorRect.new()
#		rect.set_position(position)
#		rect.set_size(cell_size)
#		tile.rect = rect
#		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
#		self.add_child(rect)
		
#func draw_tile_map():
#	print('draw_tile_map')
#	var vegetation_layer = RegionMapLayer.new()
#	self.add_child(vegetation_layer)
#	for tile in map_tiles:
#		var x = tile.x
#		var y = tile.y
#		var base_tile_type = TerrainConstants.TILE_TYPE.keys()[TerrainConstants.REGION_PARAMETERS[tile.region_type]['tile_types']['base_tile_types'][0]]
#		set_cell(x, y, tile_set.find_tile_by_name(base_tile_type))
#		if tile.tile_type != TerrainConstants.TILE_TYPE.DIRT:
#			vegetation_layer.set_cell(x, y, tile_set.find_tile_by_name(TerrainConstants.TILE_TYPE.keys()[tile.tile_type]))
#		var xx = map_size.x; var yy = map_size.y
#		if x == 0:
#			xx = x - 1
#		if x == map_size.x - 1:
#			xx = x + 1
#		if x != xx:
#			set_cell(xx, y, get_cell(x, y))
#			vegetation_layer.set_cell(xx, y, vegetation_layer.get_cell(x, y))
#		if y == 0:
#			yy = y - 1
#		if y == map_size.x - 1:
#			yy = y + 1
#		if y != yy:
#			set_cell(x, yy, get_cell(x, y))
#			vegetation_layer.set_cell(x, yy, vegetation_layer.get_cell(x, y))
#		if x != xx and y != yy:
#			set_cell(xx, yy, get_cell(x, y))
#			vegetation_layer.set_cell(xx, yy, vegetation_layer.get_cell(x, y))
#
#	update_bitmask_region(Vector2(0, 0), Vector2(map_size.x, map_size.y))
#	vegetation_layer.update_bitmask_region(Vector2(0, 0), Vector2(map_size.x, map_size.y))
		
func apply_factor(value, factor) -> float:
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	if value > 0:
		return 1 - distance
	else:
		return -1 + distance

func _init():
	# Initialize random number generator
	randomize()
	pause_mode = PAUSE_MODE_STOP
