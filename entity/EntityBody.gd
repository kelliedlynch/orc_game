extends Area2D
class_name EntityBody

var sprite_size: Vector2 = Global.tile_size
#var sprite_texture: AtlasTexture
var sprite: Sprite

func _init():
	sprite = Sprite.new()
#	sprite.texture = texture
	
func _ready():
	add_child(sprite)

func _location_changed(_model, loc: Vector2, _old):
	var pos = location_to_position(loc)
	_position_changed(pos)
	
func _position_changed(pos: Vector2):
	position = pos
	position += sprite_size / 2

func location_to_position(loc: Vector2):
	return loc * Global.tile_size
	
