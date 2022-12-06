extends OrcGameMapScene
class_name RegionMapScene

onready var region_map: RegionMap = $RegionMap
onready var inspector: TabContainer = $Inspector

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func create_region_from_tile(tile: OrcGameMapTile):
	region_map.create_tiles(tile)

func _on_BackButton_button_up():
	var new_scene = load('res://scene/WorldMapScene.tscn').instance()
#	new_scene.world_map.map_tiles = WorldData.world_map_tiles
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().remove_child(self)	

func _spawn_new_orc(x: int = -1, y: int = -1):
	var orc = OGCreatureOrc.new()
	add_child(orc)
	if x == -1 or y == -1:
		#warning-ignore:integer_division
		x = region_map.width / 2
		#warning-ignore:integer_division
		y = region_map.height / 2
	orc.location = Vector2(x, y)
	
func tiles_adjacent_to_creature(creature: CreatureModel) -> Array:
	var tile = region_map.tile_at(int(creature.location.x), int(creature.location.y))
	return region_map.tiles_adjacent_to(tile)
	
func show_inspector(position: Vector2):
	var grid = viewport_to_grid(position)
	inspector.inspect_tile(region_map.tile_at(grid.x, grid.y))

func position_to_location(location: Vector2):
	var x = int(location.x / region_map.tile_size.x)
	var y = int(location.y / region_map.tile_size.y)
	return Vector2(x, y)	

func grid_to_viewport(x: int, y: int) -> Vector2:
	var viewport_x = x * region_map.tile_size.x
	var viewport_y = y * region_map.tile_size.y
	return Vector2(viewport_x, viewport_y)
	
#func creature_at_tile(tile: OrcGameMapTile) -> CreatureModel:
#	for creature in get_tree().get_nodes_in_group('creatures'):
#		if creature.location.x == tile.x and creature.location.y == tile.y:
#			return creature
#	return null

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				show_inspector(event.position)

func _input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_SPACE:
					if event.is_pressed(): toggle_game_speed()

func toggle_game_speed():
	if Global.game_speed == Global.GameSpeed.PAUSED:
		Global.game_speed = Global.GameSpeed.NORMAL
		get_tree().paused = false
	else:
		Global.game_speed = Global.GameSpeed.PAUSED
		get_tree().paused = true
