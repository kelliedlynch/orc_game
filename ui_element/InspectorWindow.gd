extends TabContainer

enum {
	TAB_TILE,
	TAB_ITEM,
	TAB_CREATURE,
}

onready var _creature_index: int = 0 setget _set_creature_index
onready var _item_index: int = 0 setget _set_item_index
var _map: OrcGameMap setget set_current_map
func set_current_map(map: OrcGameMap):
	_map = map


var _target_location setget set_target_location, get_target_location

func set_target_location(loc):
	if _target_location != loc:
		_target_location = loc
		emit_signal("inspector_target_location_changed")
signal inspector_target_location_changed()
func get_target_location():
	return _target_location
	
#var _mouse_pointing_at: Object
var _following_mouse: bool = false setget _set_following_mouse

func _set_following_mouse(val):
	_following_mouse = val
	emit_signal('following_mouse_changed')
signal following_mouse_changed()

func _set_creature_index(val: int):
	_creature_index = val
	emit_signal('creature_index_changed', _target_location)
signal creature_index_changed()

func _set_item_index(val: int):
	_item_index = val
	emit_signal('item_index_changed', _target_location)
signal item_index_changed()


func _init():
	visible = false

func _ready():
	connect('visibility_changed', self, '_on_visibility_changed')
	connect('creature_index_changed', self, '_populate_inspector')
	connect('item_index_changed', self, '_populate_inspector')
	WorldData.connect("current_map_changed", self, "set_current_map")
	Global.connect('player_target_changed', self, '_on_player_target_changed')
	connect('following_mouse_changed', self, '_on_following_mouse_changed')
	connect('inspector_target_location_changed', self, '_reset_inspector')
#	self.creature_index = 0
#	self.item_index = 0
func _reset_inspector():
	set_current_tab(TAB_TILE)
	_creature_index = 0
	_item_index = 0

func _on_player_target_changed(ptarget: Object, _prev):
	self._set_following_mouse(!ptarget)
	if ptarget: 
		self.set_target_location(Global.get_player_target().location)
		_populate_inspector(_target_location)
	
func _set_player_target_from_location_click(loc: Vector2):
	var tile = _map.tile_at(loc)
	var target = tile
	var i = tile.get_items()
	if i.size() > 0:
		target = i.back()
	var c = tile.get_creatures()
	if c.size() > 0:
		target = c.back()
	_set_player_target(target)
	
func _set_player_target(target: Object):
	Global.set_player_target(target)

func _on_following_mouse_changed():
	if _following_mouse:
		_inspect_mouse_location()

func _inspect_mouse_location():
	_populate_inspector(SpriteManager.position_to_location(get_global_mouse_position()))

func _on_visibility_changed():
	if visible:
		if !_target_location:
			set_target_location(Global.get_player_target())
		if !_target_location:
			_set_following_mouse(true)

func _all_targets_at_location(loc: Vector2) -> Dictionary:
	var tile = _map.tile_at(loc)
	var targets = {
		'creatures': tile.get_creatures(),
		'items': tile.get_items(),
		'tile': tile,
	}
	targets.creatures.invert()
	targets.items.invert()
	return targets

func _populate_inspector(loc: Vector2) -> void:
	if loc != _target_location: set_target_location(loc)
	var targets = _all_targets_at_location(loc)
	var tab = TAB_TILE
	populate_tile_tab(targets.tile)
	if targets.items.size() > 0:
		set_tab_hidden(TAB_ITEM, false)
		tab = TAB_ITEM
		populate_item_tab(targets.items)
	else:
		set_tab_hidden(TAB_ITEM, true)
	if targets.creatures.size() > 0:
		set_tab_hidden(TAB_CREATURE, false)
		tab = TAB_CREATURE
		populate_creature_tab(targets.creatures)
	else:
		set_tab_hidden(TAB_CREATURE, true)
	set_current_tab(tab)
	visible = true

func show_next_creature():
#	if _creature_index < _creatures.size() -1:
	self._creature_index += 1
	
func show_prev_creature():
#	if _creature_index > 0:
	self._creature_index -= 1
		
func show_next_item():
#	if _item_index < _items.size() -1:
	self._item_index += 1
	
func show_prev_item():
#	if _item_index > 0:
	self._item_index -= 1
	
func populate_creature_tab(creatures) -> void:
	var creature = creatures[_creature_index]
	var isFirst = _creature_index == 0
	var isLast = _creature_index == creatures.size() - 1
	get_node("Creature/tab_header/creature_selector/prev_creature").disabled = isFirst
	get_node("Creature/tab_header/creature_selector/next_creature").disabled = isLast
	get_node("Creature/tab_header/creature_selector/creature_name").text = creature.first_name
	get_node("Creature/creature_data/creature_type/value").text = CreatureType.Type.keys()[creature.type]
	get_node("Creature/creature_data/creature_subtype/value").text = CreatureSubtype.Subtype.keys()[creature.subtype]
	get_node("Creature/creature_data/creature_location/value").text = 'x: %d, y: %d' % [creature.location.x, creature.location.y]
	
func populate_item_tab(items) -> void:
	var item = items[_item_index]
	var isFirst = _item_index == 0
	var isLast = _item_index == items.size() - 1
	get_node("Item/tab_header/item_selector/prev_item").disabled = isFirst
	get_node("Item/tab_header/item_selector/next_item").disabled = isLast
	get_node("Item/tab_header/item_selector/item_name").text = item.item_name
	get_node("Item/item_data/item_size/value").text = '%s' % item.size
	get_node("Item/item_data/item_weight/value").text = '%s' % item.weight
	get_node("Item/item_data/item_location/value").text = 'x: %d, y: %d' % [item.location.x, item.location.y]
	
func populate_tile_tab(tile):
	get_node("Tile/col1/tile_location/value").text = 'x: %d, y: %d' % [tile.location.x, tile.location.y]
	get_node("Tile/col1/tile_elevation/value").text = '%s' % tile.elevation
	get_node("Tile/col2/tile_type/value").text = TileType.Type.keys()[tile.tile_type]
	get_node("Tile/col2/tile_soil_quality/value").text = '%s' % tile.soil_quality

func _unhandled_input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_ESCAPE:
					if event.is_pressed(): Global.set_player_target(null)
				KEY_I:
					if event.is_pressed(): visible = !visible
		'InputEventMouseMotion':
			if _following_mouse:
				_inspect_mouse_location()
			
		'InputEventMouseButton':
			if event.is_pressed() && event.button_index == BUTTON_LEFT:
				_set_player_target_from_location_click(SpriteManager.position_to_location(event.position))

