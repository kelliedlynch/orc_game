extends Object
class_name OrcGameMapTile

var location: Vector2
var tile_size: Vector2

var region_type: int = 2

# Tile Properties will range from -1 to +1, with 0 being baseline for temperate grassland or
# forest at about sea level. 
var elevation: float = 0.0
var temperature: float = 0.0
var terrain_intensity: float = 0.0
var wind_intensity: float = 0.0
var precipitation: float = 0.0
var soil_quality: float = 0.0

func _init(_x: int, _y: int):
	location = Vector2(_x, _y)
