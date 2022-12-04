extends Node
class_name OrcGameMapScene

var tile_size: Vector2 = Vector2(16, 16)

func viewport_to_grid(location: Vector2):
	var x = int(location.x / tile_size.x)
	var y = int(location.y / tile_size.y)
	return Vector2(x, y)	

func grid_to_viewport(x: int, y: int) -> Vector2:
	var viewport_x = x * tile_size.x
	var viewport_y = y * tile_size.y
	return Vector2(viewport_x, viewport_y)
