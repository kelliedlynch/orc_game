extends Area2D
class_name CreatureBody

var sprite_size = Vector2(16.0, 16.0)
var sprite_texture: AtlasTexture
var sprite: Sprite
#var model: CreatureModel

func _init(texture: AtlasTexture):
	sprite = Sprite.new()
	sprite_texture = texture
	
func _ready():
	sprite.texture = sprite_texture
	add_child(sprite)

func move_to_coords(coords: Vector2):
	position = coords
	position += sprite_size / 2




		
#func set_map_position(x, y):
#	map_position.x = x
#	map_position.y = y
#	position = Vector2(x, y) * tile_size
#	position += Vector2.ONE * tile_size/2
	
#func step_along_path(path: Array):
#	if path.size() > 0:
#		var next_step = path[0]
#		var coords = Global.pathfinder.index_to_xy(next_step)
#		set_map_position(coords.x, coords.y)
#		path.remove(0)
#	return path
#
#func move_by(dx: int, dy: int):
#	var new_x = map_position.x + dx
#	var new_y = map_position.y + dy
#	if (new_x < 0 or new_x >= map.map_size.x
#		or new_y < 0 or new_y >= map.map_size.y):
#		push_error(self.to_string() + ' tried to go off-screen at ' + str(new_x) + ', ' + str(new_y))
#		return
#	map_position.x += dx
#	map_position.y += dy
#	position += Vector2(dx, dy) * tile_size
#
#func _on_unhandled_input(event):
#	print(event)	



