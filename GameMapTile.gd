extends Node
class_name GameMapTile

var plateId: int
# these properties range from -1 to 1
var elevation: float
var temperature: float

# these properties range from 0 to 1
var seismic_activity: float
var wind_intensity: float
var precipitation: float
var soil_quality: float

var type: String

var location: Dictionary
var rect: ColorRect

func _init(x: int, y: int):
	location = {'x': x, 'y': y}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _to_string():
	var string = "GameMapTile at " + str(location.x) + ", " + str(location.y) + "\n"
	string += "soil_quality: " + str(soil_quality) + "\n"
	string += "elevation: " + str(elevation) + "\n"
	string += "temperature: " + str(temperature) + "\n"
	string += "seismic_activity: " + str(seismic_activity) + "\n"
	string += "wind_intensity: " + str(wind_intensity) + "\n"
	string += "precipitation: " + str(precipitation) + "\n"
	string += "tile type: " + type
	return string

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
