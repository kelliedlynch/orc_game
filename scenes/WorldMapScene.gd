extends Node2D

#const RegionMapScene = preload('res://scenes/RegionMapScene.gd')
#const WorldMap = preload('res://maps/worldmap/WorldMap.gd')

var world_map: WorldMap

func _enter_tree():
	world_map = get_node("GameWorldMap")
	var tiles = WorldData.world_map_tiles
	if tiles.size() > 0:
		world_map.load_map_from_tiles(tiles)
	else:
		world_map.generate_map_tiles()

func _on_confirm_enter_region(tile: WorldMapTile):
	WorldData.world_map_tiles = world_map.map_tiles
	var new_scene = load('res://scenes/RegionMapScene.tscn').instance()
	new_scene.create_region_from_tile(tile)
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().remove_child(self)

func _on_NewWorld_button_up():
	for tile in world_map.map_tiles:
		tile.rect.queue_free()
	world_map.map_tiles = []
	world_map.generate_map_tiles()
	world_map.draw_rect_map()
	world_map.color_world_map()

#func _unhandled_input(event):
#	if event is InputEventMouseButton and event.is_pressed():
#		var target_location = world_to_map(event.position)
#		var tile = tile_at(target_location.x, target_location.y)
#		if !dialog_window.visible:
#			dialog_window.window_title = "window title"
#			dialog_window.dialog_text = "dialog text"
#			self.add_child(dialog_window)
#			dialog_window.popup_centered()
#			dialog_window.get_ok().connect('button_up', self.get_parent(), '_on_confirm_enter_region', [tile])
#			dialog_window.get_cancel().connect("button_up", self, '_on_cancel_dialog_window')
