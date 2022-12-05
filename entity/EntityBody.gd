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

func place_at_position(pos: Vector2):
	position = pos
	position += sprite_size / 2
