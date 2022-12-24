extends Node
class_name OrcGameMap

var map_tiles: Array

# A map is a collection of tiles in a coordinate system
# It knows nothing about the game window or how those coordinates relate to the world outside.

func _init():
	pause_mode = PAUSE_MODE_STOP
	

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise
	
func location_to_index(loc: Vector2) -> int:
	return int(loc.y * Global.map_size.x + loc.x)

func index_to_location(index: int) -> Vector2:
	return Vector2(index % Global.map_size.x, index / Global.map_size.x)

func tile_at(loc: Vector2) -> OrcGameMapTile:
	if loc.x > Global.map_size.x - 1:
		push_error("Coord x:" + str(loc.x) + " out of bounds")
		return null
	if loc.y > Global.map_size.y - 1:
		push_error("Coord y:" + str(loc.y) + " out of bounds")
		return null
	var index = location_to_index(loc)
	return map_tiles[index]

#func tile_at_viewport_position(position: Vector2):
#	var grid_loc = viewport_to_grid(position)
#	return tile_at(grid_loc.x, grid_loc.y)
func locations_adjacent_to(loc: Vector2) -> Array:
	var adjacent = [
		loc + Vector2.LEFT + Vector2.UP,
		loc + Vector2.UP,
		loc + Vector2.RIGHT + Vector2.UP,
		loc + Vector2.RIGHT,
		loc + Vector2.RIGHT + Vector2.DOWN,
		loc + Vector2.DOWN,
		loc + Vector2.LEFT + Vector2.DOWN,
		loc + Vector2.LEFT
	]
	if loc.x <= 0:
		adjacent[0] = null
		adjacent[6] = null
		adjacent[7] = null
	if loc.x >= Global.map_size.x - 1:
		adjacent[2] = null
		adjacent[3] = null
		adjacent[4] = null
	if loc.y <= 0:
		adjacent[0] = null
		adjacent[1] = null
		adjacent[2] = null
	if loc.y >= Global.map_size.y - 1:
		adjacent[4] = null
		adjacent[5] = null
		adjacent[6] = null
	
	while adjacent.has(null):
		adjacent.remove(adjacent.find(null))
	return adjacent

func tiles_adjacent_to(tile: OrcGameMapTile) -> Array:
	var tiles = []
	for location in locations_adjacent_to(tile.location):
		tiles.append(tile_at(location))
	return tiles

#	if tile.x > 0:
#		tiles.append(tile_at(Vector2(tile.x - 1, tile.y)))
#		if tile.y > 0:
#			tiles.append(tile_at(Vector2(tile.x - 1, tile.y - 1)))
#		if tile.y < Global.map_size.y - 1:
#			tiles.append(tile_at(Vector2(tile.x - 1, tile.y + 1)))
#	if tile.y > 0:
#		tiles.append(tile_at(Vector2(tile.x, tile.y - 1)))
#	if tile.y < Global.map_size.y - 1:
#		tiles.append(tile_at(Vector2(tile.x, tile.y + 1)))
#	if tile.x < Global.map_size.x - 1:
#		tiles.append(tile_at(Vector2(tile.x + 1, tile.y)))
#		if tile.y > 0:
#			tiles.append(tile_at(Vector2(tile.x + 1, tile.y - 1)))
#		if tile.y < Global.map_size.y - 1:
#			tiles.append(tile_at(Vector2(tile.x + 1, tile.y + 1)))
#	return tiles
#
#func tiles_orthogonal_to(tile: OrcGameMapTile) -> Array:
#	var tiles = []
#	if tile.x > 0:
#		tiles.append(tile_at(Vector2(tile.x - 1, tile.y)))
#	if tile.x < Global.map_size.x - 1:
#		tiles.append(tile_at(Vector2(tile.x + 1, tile.y)))
#	if tile.y > 0:
#		tiles.append(tile_at(Vector2(tile.x, tile.y - 1)))
#	if tile.y < Global.map_size.y - 1:
#		tiles.append(tile_at(Vector2(tile.x, tile.y + 1)))
#	return tiles
	
func apply_factor(value, factor) -> float:
	# Adjusts value based on factor. Negative factor moves value toward zero. Positive moves away.
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	if value > 0:
		return 1 - distance
	else:
		return -1 + distance
