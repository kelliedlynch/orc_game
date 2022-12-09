extends TileMap
class_name OrcGameMapLayer

var size: Vector2

func _init():
	pass

func _enter_tree():
	var cell_size = Global.tile_size
	set_cell_size(cell_size)

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
