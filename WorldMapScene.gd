extends Node2D

const RegionMapScene = preload('res://RegionMapScene.gd')

var world_map: WorldMap

func _init():
	world_map = WorldMap.new()

func _on_confirm_enter_region(tile: WorldMapTile):
	var node = RegionMapScene.new(tile)
#	var new_scene = PackedScene.new()
#	var result = new_scene.pack(node)
#	get_tree().set_current_scene(node)
	get_tree().get_root().add_child(node)
	get_tree().get_root().remove_child(self)
	
#	get_tree().change_scene_to(node)
	
