extends Object
class_name OrcGameMapTile

var x: int = 0
var y: int = 0
var tile_size: Vector2

# Tile Properties will range from -1 to +1, with 0 being baseline for temperate grassland or
# forest at about sea level. 
var elevation: float = 0.0
var temperature: float = 0.0
var terrain_intensity: float = 0.0
var wind_intensity: float = 0.0
var precipitation: float = 0.0
var soil_quality: float = 0.0

var region_type: int = 2

func _init(_x: int, _y: int):
	x = _x
	y = _y
