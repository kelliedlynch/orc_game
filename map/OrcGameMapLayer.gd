extends TileMap
class_name OrcGameMapLayer

# Map dimensions, generate these another way later
var width: int
var height: int
#var tiles: Array

func _init():
	pass

func _enter_tree():
	var cell_size = get_parent().tile_size
	set_cell_size(cell_size)
	var size = get_viewport().size
	width = int(size.x / cell_size.x)
	height = int(size.y / cell_size.y)

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0) -> OpenSimplexNoise: 
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise

func apply_factor(value, factor):
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	return 1 - distance if value > 0 else -1 + distance
