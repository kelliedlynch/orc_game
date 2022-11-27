extends TileMap

# Map dimensions, generate these another way later
var map_size: Dictionary = { 'x': 64, 'y': 37}
var map_tiles: Array

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise

func tile_at(x: int, y: int):
	if x > map_size.x:
		push_error("Coord x:" + str(x) + " out of bounds")
		return null
	if y > map_size.y:
		push_error("Coord y:" + str(y) + " out of bounds")
		return null
	var index = y * map_size.x + x
	return map_tiles[index]

func tiles_adjacent_to(tile: OrcGameMapTile):
	var tiles = []
	if tile.location.x > 0:
		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
		if tile.location.y > 0:
			tiles.append(tile_at(tile.location.x - 1, tile.location.y - 1))
		if tile.location.y < map_size.y - 1:
			tiles.append(tile_at(tile.location.x - 1, tile.location.y + 1))	
	if tile.location.y > 0:
		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
	if tile.location.y < map_size.y - 1:
		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
	if tile.location.x < map_size.x - 1:
		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
		if tile.location.y > 0:
			tiles.append(tile_at(tile.location.x + 1, tile.location.y - 1))
		if tile.location.y < map_size.y - 1:
			tiles.append(tile_at(tile.location.x + 1, tile.location.y + 1))
	return tiles

func tiles_orthogonal_to(tile: OrcGameMapTile):
	var tiles = []
	if tile.location.x > 0:
		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
	if tile.location.x < map_size.x - 1:
		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
	if tile.location.y > 0:
		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
	if tile.location.y < map_size.y - 1:
		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
	return tiles
	
func draw_map():
	for tile in map_tiles:
		var position = map_to_world(Vector2(tile.location.x, tile.location.y))
		var rect = ColorRect.new()
		rect.set_position(position)
		rect.set_size(cell_size)
		tile.rect = rect
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		self.add_child(rect)

func _init():
	print('OrcGameMap init')
	set_cell_size(Vector2(16.0, 16.0))
	# Initialize random number generator
	randomize()
	
func _ready():
	print('OrcGameMap ready')

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
