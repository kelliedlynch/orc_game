extends "res://maps/OrcGameMap.gd"
class_name RegionMap

const RegionMapTile = preload("res://maps/regionmap/RegionMapTile.gd")

func _init():
	prints('RegionMap init')
#	create_tiles(world_tile)

func create_tiles(world_tile: WorldMapTile):
	var elevation_noise = init_noise( int(floor(world_tile.seismic_activity * 5.0)), 10.0 + 50.0 * (1.0 - world_tile.elevation), abs(world_tile.elevation), 1.0 + 2.0 * world_tile.seismic_activity)
	var soil_quality_noise = init_noise(3, 20.0, world_tile.soil_quality, 2.0)
	for i in range(map_size.x * map_size.y):
		var x = i % map_size.x
		var y = floor(i / map_size.x)
		var tile = RegionMapTile.new(x, y)
		tile.elevation = elevation_noise.get_noise_2d(x, y)
		tile.soil_quality = apply_factor(world_tile.soil_quality, soil_quality_noise.get_noise_2d(x, y))
		if tile.soil_quality > 0.5:
			tile.tile_type = TerrainConstants.TILE_TYPE.GRASS
		else:
			tile.tile_type = TerrainConstants.TILE_TYPE.DIRT
		map_tiles.append(tile)


func color_tiles():
	print('coloring tiles')
	for tile in map_tiles:
		var red = (tile.elevation + 1) / 2
		var green = red
		var blue = red

		var color = Color(red, green, blue, 1)
		tile.rect.color = color

func _ready():
	draw_tile_map()
	
func _to_string():
	var string = 'RegionMap'
#	var string = "RegionMap with tile " + str(world_tile)
#	string += 'map tile 0 ' + str(map_tiles[0])
	return string
