extends TabContainer

enum {
	TAB_TILE,
	TAB_BUILT,
	TAB_ITEM,
	TAB_CREATURE,
}

var creature_index: int = 0 
var item_index: int = 0 
var built_index: int = 0 

var _map: OrcGameMap setget set_current_map

func set_current_map(map: OrcGameMap):
	_map = map
	
var old_tab

func _init():
	visible = false

func _ready():
#	connect('visibility_changed', self, '_on_visibility_changed')
	set_tab_hidden(TAB_CREATURE, true)
	set_tab_hidden(TAB_ITEM, true)
	set_tab_hidden(TAB_BUILT, true)
		
	WorldData.connect("current_map_changed", self, "set_current_map")
	Global.connect('player_target_changed', self, '_on_player_target_changed')
	connect('tab_selected', self, 'on_tab_changed')

func _process(_delta):
	if visible:
		populate_inspector()

func _on_player_target_changed(ptarget: Object, _prev):
	if old_tab != current_tab:
		if ptarget is OGCreature and current_tab != TAB_CREATURE:
			current_tab = TAB_CREATURE
		elif ptarget is OGItem and current_tab != TAB_ITEM:
			current_tab = TAB_ITEM
		elif ptarget is OGBuilt and current_tab != TAB_BUILT:
			current_tab = TAB_BUILT
		elif ptarget is OrcGameMapTile and current_tab != TAB_TILE:
			current_tab = TAB_TILE
		if ptarget and !visible:
			visible = true

		
func _set_player_target_from_position_click(pos: Vector2):
	var loc = SpriteManager.position_to_location(pos)
	var targets = _all_targets_at_location(loc)
	var target
	if !targets[TAB_CREATURE].empty():
		target = targets[TAB_CREATURE].back()
		old_tab = TAB_CREATURE
	elif !targets[TAB_ITEM].empty():
		target = targets[TAB_ITEM].back()
		old_tab = TAB_ITEM
	elif !targets[TAB_BUILT].empty():
		target = targets[TAB_BUILT].back()
		old_tab = TAB_BUILT
	else:
		target = targets[TAB_TILE]
		old_tab = TAB_TILE
	Global.set_player_target(target)

func _all_targets_at_location(loc: Vector2) -> Dictionary:
	var tile = _map.tile_at(loc)
	var targets = {
		TAB_CREATURE: tile.get_creatures(),
		TAB_ITEM: tile.get_items(),
		TAB_BUILT: tile.get_builts(),
		TAB_TILE: tile,
	}
	targets[TAB_CREATURE].invert()
	targets[TAB_ITEM].invert()
	targets[TAB_BUILT].invert()
	return targets
	
func populate_inspector():
	var target_loc: Vector2
	var player_target = Global.get_player_target()
	if player_target:
		target_loc = player_target.location
	else:
		target_loc = SpriteManager.position_to_location(get_global_mouse_position())
	var targets = _all_targets_at_location(target_loc)
	
	if current_tab == TAB_CREATURE:
		set_tab_hidden(TAB_CREATURE, false)
		populate_creature_tab(targets[TAB_CREATURE])
	elif current_tab == TAB_ITEM:
		print('showing item tab')
		set_tab_hidden(TAB_ITEM, false)
		populate_item_tab(targets[TAB_ITEM])
	elif current_tab == TAB_BUILT:
		set_tab_hidden(TAB_BUILT, false)
		populate_built_tab(targets[TAB_BUILT])
	elif current_tab == TAB_TILE:
#		print('populating tile tab')
		populate_tile_tab(targets[TAB_TILE])
	if !get_tab_hidden(TAB_CREATURE) and targets[TAB_CREATURE].empty():
		set_tab_hidden(TAB_CREATURE, true)
	elif get_tab_hidden(TAB_CREATURE) and !targets[TAB_CREATURE].empty():
		set_tab_hidden(TAB_CREATURE, false)
	if !get_tab_hidden(TAB_ITEM) and targets[TAB_ITEM].empty():
		print('hiding item tab')
		set_tab_hidden(TAB_ITEM, true)
	elif get_tab_hidden(TAB_ITEM) and !targets[TAB_ITEM].empty():
		print('showing item tab')
		set_tab_hidden(TAB_ITEM, false)
	if !get_tab_hidden(TAB_BUILT) and targets[TAB_BUILT].empty():
		set_tab_hidden(TAB_BUILT, true)
	elif get_tab_hidden(TAB_BUILT) and !targets[TAB_BUILT].empty():
		set_tab_hidden(TAB_BUILT, false)
#	print('finished populating and hiding tabs')
	
func on_tab_changed(tab):
	var targets = _all_targets_at_location(Global.get_player_target().location)
	if old_tab == current_tab:
		if tab == TAB_CREATURE:
			Global.set_player_target(targets[TAB_CREATURE][creature_index])
		elif tab == TAB_ITEM:
			Global.set_player_target(targets[TAB_ITEM][item_index])
		elif tab == TAB_BUILT:
			Global.set_player_target(targets[TAB_BUILT][built_index])
		elif tab == TAB_TILE:
			Global.set_player_target(targets[TAB_TILE])
	
		
func show_next():
	match current_tab:
		TAB_CREATURE:
			creature_index += 1
		TAB_ITEM:
			item_index += 1
		TAB_BUILT:
			built_index += 1
	on_tab_changed(current_tab)

func show_prev():
	match current_tab:
		TAB_CREATURE:
			creature_index -= 1
		TAB_ITEM:
			item_index -= 1
		TAB_BUILT:
			built_index -= 1
	on_tab_changed(current_tab)
	
func populate_creature_tab(creatures) -> void:
	var creature = creatures[creature_index]
#	current_target = creature
	var isFirst = creature_index == 0
	var isLast = creature_index == creatures.size() - 1
	get_node("Creature/tab_header/creature_selector/prev_creature").disabled = isFirst
	get_node("Creature/tab_header/creature_selector/next_creature").disabled = isLast
	get_node("Creature/tab_header/creature_selector/creature_name").text = creature.first_name
	get_node("Creature/creature_data/creature_type/value").text = Creature.Type.keys()[creature.type]
	get_node("Creature/creature_data/creature_subtype/value").text = Creature.Subtype.keys()[creature.subtype]
	get_node("Creature/creature_data/creature_location/value").text = 'x: %d, y: %d' % [creature.location.x, creature.location.y]
	get_node("Creature/creature_data/creature_goal/value").text = creature.current_goal.get_class() if creature.current_goal else 'None'
	get_node("Creature/creature_data/creature_action/value").text = creature.current_plan.back().action.get_class() if !creature.current_plan.empty() else 'None'
	
func populate_item_tab(items) -> void:
#	print('populate_item_tab')
	var item = items[item_index]
#	current_target = item
	var isFirst = item_index == 0
	var isLast = item_index == items.size() - 1
	get_node("Item/tab_header/item_selector/prev_item").disabled = isFirst
	get_node("Item/tab_header/item_selector/next_item").disabled = isLast
	get_node("Item/tab_header/item_selector/item_name").text = item.instance_name
	get_node("Item/item_data/item_size/value").text = '%s' % item.size
	get_node("Item/item_data/item_weight/value").text = '%s' % item.weight
	get_node("Item/item_data/item_location/value").text = 'x: %d, y: %d' % [item.location.x, item.location.y]
	
func populate_built_tab(builts) -> void:
	var built = builts[built_index]
#	current_target = built
	var isFirst = built_index == 0
	var isLast = built_index == builts.size() - 1
	get_node("Built/tab_header/built_selector/prev_built").disabled = isFirst
	get_node("Built/tab_header/built_selector/next_built").disabled = isLast
	get_node("Built/tab_header/built_selector/built_name").text = built.instance_name
	get_node("Built/built_data/built_size/value").text = '%s' % built.size
	get_node("Built/built_data/built_weight/value").text = '%s' % built.weight
	get_node("Built/built_data/built_location/value").text = 'x: %d, y: %d' % [built.location.x, built.location.y]
	
func populate_tile_tab(tile):
#	print('populate_tile_tab')
#	current_target = tile
	get_node("Tile/col1/tile_location/value").text = 'x: %d, y: %d' % [tile.location.x, tile.location.y]
	get_node("Tile/col1/tile_elevation/value").text = '%s' % tile.elevation
	get_node("Tile/col2/tile_type/value").text = TileType.Type.keys()[tile.tile_type]
	get_node("Tile/col2/tile_soil_quality/value").text = '%s' % tile.soil_quality

func _unhandled_input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_ESCAPE:
					if event.is_pressed(): 
						if Global.get_player_target():
							Global.set_player_target(null)
						elif visible: visible = false
				KEY_I:
					if event.is_pressed(): visible = !visible
		'InputEventMouseButton':
			if event.button_index == BUTTON_LEFT and event.is_pressed():
				_set_player_target_from_position_click(event.position)
