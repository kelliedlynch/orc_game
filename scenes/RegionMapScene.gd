extends Node2D

var region_map: RegionMap
#var world_map_tile: WorldMapTile

func create_region_from_tile(tile: WorldMapTile):
	get_node("RegionMap").create_tiles(tile)

func _on_BackButton_button_up():
	var new_scene = load('res://scenes/WorldMapScene.tscn').instance()
#	new_scene.world_map.map_tiles = WorldData.world_map_tiles
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().remove_child(self)	

func _enter_tree():
	if self.name == 'OrcTest':
		var default_tile = WorldMapTile.new(1, 1)
		create_region_from_tile(default_tile)

