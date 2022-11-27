extends "res://OrcGameMap.gd"
class_name RegionMap

const RegionMapTile = preload("res://RegionMapTile.gd")

#const WorldMapTile = preload("res://WorldMapTile.gd")
#var world_map_tile: WorldMapTile

func _init(world_tile: WorldMapTile):
	prints('RegionMap init', world_tile)
	create_tiles(world_tile)

func create_tiles(world_tile: WorldMapTile):
	print('RegionMap create_tiles')
	var elevation_noise = init_noise( floor(world_tile.seismic_activity * 5), 10 + 50 * 1 - world_tile.elevation, world_tile.elevation, 1.0 + 2 * world_tile.seismic_activity)
	for i in range(map_size.x * map_size.y):
		var x = i % map_size.x
		var y = floor(i / map_size.x)
		var tile = RegionMapTile.new(x, y, world_tile)
		tile.elevation = elevation_noise.get_noise_2d(x, y)
		map_tiles.append(tile)


func color_tiles():
	print('coloring tiles')
	for tile in map_tiles:
		var red = (tile.elevation + 1) / 2
		var green = red
		var blue = red

		var color = Color(red, green, blue, 1)
		tile.rect.color = color
	pass

func _ready():
	print('scene ready')
	draw_map()
	color_tiles()
	
func _to_string():
	var string = 'RegionMap'
#	var string = "RegionMap with tile " + str(world_tile)
#	string += 'map tile 0 ' + str(map_tiles[0])
	return string
