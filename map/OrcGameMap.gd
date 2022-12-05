extends Node2D
class_name OrcGameMap

var width: int
var height: int
var tile_size: Vector2
var map_tiles: Array

func _init():
	# Initialize random number generator
	randomize()
	pause_mode = PAUSE_MODE_STOP
	
func _enter_tree():
	tile_size = get_parent().tile_size
	width = int(get_viewport_rect().size.x / tile_size.x)
	height = int(get_viewport_rect().size.y / tile_size.y)

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise

func tile_at(x: int, y: int) -> OrcGameMapTile:
	if x > width:
		push_error("Coord x:" + str(x) + " out of bounds")
		return null
	if y > height:
		push_error("Coord y:" + str(y) + " out of bounds")
		return null
	var index = y * width + x
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
		if tile.y < height - 1:
			tiles.append(tile_at(tile.x - 1, tile.y + 1))	
	if tile.y > 0:
		tiles.append(tile_at(tile.x, tile.y - 1))
	if tile.y < height - 1:
		tiles.append(tile_at(tile.x, tile.y + 1))
	if tile.x < width - 1:
		tiles.append(tile_at(tile.x + 1, tile.y))
		if tile.y > 0:
			tiles.append(tile_at(tile.x + 1, tile.y - 1))
		if tile.y < height - 1:
			tiles.append(tile_at(tile.x + 1, tile.y + 1))
	return tiles

func tiles_orthogonal_to(tile: OrcGameMapTile) -> Array:
	var tiles = []
	if tile.x > 0:
		tiles.append(tile_at(tile.x - 1, tile.y))
	if tile.x < width - 1:
		tiles.append(tile_at(tile.x + 1, tile.y))
	if tile.y > 0:
		tiles.append(tile_at(tile.x, tile.y - 1))
	if tile.y < height - 1:
		tiles.append(tile_at(tile.x, tile.y + 1))
	return tiles
	
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
