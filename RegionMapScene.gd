extends Node2D

var region_map: RegionMap
var world_map_tile: WorldMapTile


func _init(world_tile: WorldMapTile):
	print('RegionMapScene init')
	world_map_tile = world_tile
	region_map = RegionMap.new(world_map_tile)
	self.add_child(region_map)
	prints("children of regionmapscene", get_children())

func _ready():
	print('RegionMapScene ready')
