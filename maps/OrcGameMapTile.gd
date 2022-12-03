extends Node
class_name OrcGameMapTile

var x: int = 0
var y: int = 0

# these properties range from -1 to 1
var elevation: float = 0.0
var temperature: float = 0.0

# these properties range from 0 to 1
var seismic_activity: float = 0.5
var wind_intensity: float = 0.5
var precipitation: float = 0.2
var soil_quality: float = 0.2

var region_type: int = 2

var rect: ColorRect

func _init(_x: int, _y: int):
	x = _x
	y = _y
