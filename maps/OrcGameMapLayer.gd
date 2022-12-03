extends TileMap
class_name OrcGameMapLayer

const TerrainConstants = preload('res://maps/TerrainConstants.gd')
# Map dimensions, generate these another way later
var size: Dictionary = { 'x': 64, 'y': 37}
var tiles: Array

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise


#
#func tiles_adjacent_to(tile: OrcGameMapTile):
#	var tiles = []
#	if tile.location.x > 0:
#		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
#		if tile.location.y > 0:
#			tiles.append(tile_at(tile.location.x - 1, tile.location.y - 1))
#		if tile.location.y < size.y - 1:
#			tiles.append(tile_at(tile.location.x - 1, tile.location.y + 1))	
#	if tile.location.y > 0:
#		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
#	if tile.location.y < size.y - 1:
#		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
#	if tile.location.x < size.x - 1:
#		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
#		if tile.location.y > 0:
#			tiles.append(tile_at(tile.location.x + 1, tile.location.y - 1))
#		if tile.location.y < size.y - 1:
#			tiles.append(tile_at(tile.location.x + 1, tile.location.y + 1))
#	return tiles
#
#func tiles_orthogonal_to(tile: OrcGameMapTile):
#	var tiles = []
#	if tile.location.x > 0:
#		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
#	if tile.location.x < size.x - 1:
#		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
#	if tile.location.y > 0:
#		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
#	if tile.location.y < size.y - 1:
#		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
#	return tiles
	

		
func apply_factor(value, factor):
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	return 1 - distance if value > 0 else -1 + distance
