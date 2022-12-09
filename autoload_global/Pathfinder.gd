extends AStar2D
class_name Pathfinder

var width = Global.map_size.x
var height = Global.map_size.y

func get_path(from: Vector2, to: Vector2):
	var path = get_point_path(location_to_index(from), location_to_index(to))
	path.remove(0)
	return path
	
func index_to_location(index):
	var x = index % width
	var y = int(floor(index / width))
	return Vector2(x, y)
	
func location_to_index(loc: Vector2):
	return int((loc.y * width) + loc.x)
