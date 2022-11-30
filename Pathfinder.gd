extends AStar2D
class_name Pathfinder

var width = WorldData.region_width
var height = WorldData.region_height

func index_to_xy(index):
	var x = index % width
	var y = int(floor(index / width))
	return { 'x': x, 'y': y }
	
func xy_to_index(x, y):
	return int((y * width) + x)
