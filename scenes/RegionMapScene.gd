extends Node2D
class_name RegionMapScene

var region_map: RegionMap
var inspector: TabContainer

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _ready():
	load_inspector()

func create_region_from_tile(tile: WorldMapTile):
	region_map = RegionMap.new()
	add_child(region_map)
	region_map.create_tiles(tile)

func _on_BackButton_button_up():
	var new_scene = load('res://scenes/WorldMapScene.tscn').instance()
#	new_scene.world_map.map_tiles = WorldData.world_map_tiles
	get_tree().get_root().add_child(new_scene)
	get_tree().get_root().remove_child(self)	

func _spawn_new_orc(x: int = -1, y: int = -1):
	var Orc = load('res://creatures/orcs/Orc.gd')
	var orc = Orc.new()
	add_child(orc)
	if x == -1 or y == -1:
		x = int(region_map.map_size.x / 2)
		y = int(region_map.map_size.y / 2)
	var tile = region_map.tile_at(x, y)
	orc.move_to_tile(tile)
	
func find_adjacent_tiles(creature: CreatureModel) -> Array:
	return region_map.tiles_adjacent_to(region_map.tile_at(creature.x, creature.y))
	
func load_inspector():
	inspector = Inspector.new()
	add_child(inspector)
	
func show_inspector(position: Vector2):
	var data = {}
	var grid = viewport_to_grid(position)
	data.tile = region_map.tile_at(grid.x, grid.y)
	data.creature = creature_at_tile(data.tile)
	inspector.inspect(data)

func viewport_to_grid(location: Vector2):
	var x = int(location.x / region_map.tile_size.x)
	var y = int(location.y / region_map.tile_size.y)
	return Vector2(x, y)	

func grid_to_viewport(x: int, y: int) -> Vector2:
	var viewport_x = x * region_map.tile_size.x
	var viewport_y = y * region_map.tile_size.y
	return Vector2(viewport_x, viewport_y)
	
func creature_at_tile(tile: OrcGameMapTile) -> CreatureModel:
	for creature in get_tree().get_nodes_in_group('creatures'):
		if creature.x == tile.x and creature.y == tile.y:
			return creature
	return null

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				show_inspector(event.position)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_SPACE:
				toggle_game_speed()
			if event.get_scancode() == KEY_ESCAPE:
				inspector.hide()
		
		
func toggle_game_speed():
	if Global.game_speed == Global.GAME_SPEED.PAUSED:
		Global.game_speed = Global.GAME_SPEED.NORMAL
		get_tree().paused = false
	else:
		Global.game_speed = Global.GAME_SPEED.PAUSED
		get_tree().paused = true
