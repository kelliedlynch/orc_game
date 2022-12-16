extends OrcGameMapController
#class_name WorldMapScene
#const RegionMapScene = preload('res://scenes/RegionMapScene.gd')
#const WorldMap = preload('res://maps/worldmap/WorldMap.gd')

onready var world_map: WorldMap = $WorldMap

func _on_confirm_enter_region(tile: OrcGameMapTile):
	WorldData.world_map_tiles = world_map.map_tiles
	var new_scene = load('res://scenes/RegionMapScene.tscn').instance()
	new_scene.create_region_from_tile(tile)
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().remove_child(self)

func _on_NewWorld_button_up():
	world_map.map_tiles = []
	world_map.generate_map_tiles()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT and !event.is_pressed():
		print('create region map')
