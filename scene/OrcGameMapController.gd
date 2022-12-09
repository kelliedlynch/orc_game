extends Node
class_name OrcGameMapController

# a MapController controls display of the map: which region of the map is currently on screen
# it also handles converting from screen/viewport coordinates to map coordinates

var zoom_level: int = 1

var map: OrcGameMap

# _base_tile_size is the size everything is derived from, and is equal to the default tile
# size of the sprite sheets the game uses
onready var _base_tile_size: Vector2 = Global.tile_size
# tile_size is the size of a single tile at the current zoom level
# cameras may make this pointless
var tile_size: Vector2 setget , _get_tile_size

func _get_tile_size():
	return Vector2(_base_tile_size.x * zoom_level, _base_tile_size.y * zoom_level)
	
func _ready():
	pass
	

