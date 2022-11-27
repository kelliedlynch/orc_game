extends Node
class_name OrcGameMapTile

var location = { 'x': 0, 'y': 0}

# these properties range from -1 to 1
var elevation: float
var temperature: float

# these properties range from 0 to 1
var seismic_activity: float
var wind_intensity: float
var precipitation: float
var soil_quality: float

var region_type: String

var rect: ColorRect

func _init(x: int, y: int):
	location = {'x': x, 'y': y}
