extends TabContainer

enum {
	TAB_TILE,
	TAB_ITEM,
	TAB_CREATURE,
}

onready var creature_index: int = 0 setget _set_creature_index
onready var item_index: int = 0 setget _set_item_index
var _creatures: Array = []
var _items: Array = []
var _tile: RegionMapTile

onready var _selected = null setget _set_selected
onready var _target = _selected 
var _mouse_pointing_at
var _following_mouse

func _set_creature_index(val: int):
	creature_index = val
	emit_signal('creature_index_changed')
signal creature_index_changed()

func _set_item_index(val: int):
	item_index = val
	emit_signal('item_index_changed')
signal item_index_changed()

func _set_selected(val):
	_selected = val
	emit_signal('selected_changed')
signal selected_changed()


func _init():
	visible = false

func _ready():
	connect('visibility_changed', self, '_on_visibility_changed')
	connect('selected_changed', self, '_on_selected_changed')
	connect('creature_index_changed', self, 'populate_creature_tab')
	connect('item_index_changed', self, 'populate_item_tab')
#	self.creature_index = 0
#	self.item_index = 0

func _on_selected_changed():
	if !_selected: return
	_target = _selected
	_populate_inspector()
	if _target is OGItem:
		set_current_tab(TAB_ITEM)
#		inspect_item(_target)
	elif _target is OGCreature:
		set_current_tab(TAB_CREATURE)
#		inspect_creature(_target)
	elif _target is RegionMapTile:
		set_current_tab(TAB_TILE)
#		inspect_tile(_target)


func _on_visibility_changed():
	if visible == false:
		return
	_target = _selected if _selected else  _mouse_pointing_at
	if _selected:
		_target = _selected
		_following_mouse = false
	else:
		_target = _mouse_pointing_at
		_following_mouse = true

func _get_target_at_location(loc: Vector2):
	_creatures = CreatureManager.get_creatures_at_location(loc)
	_items = ItemManager.get_items_at_location(loc)
	_tile = get_parent().map.tile_at(loc)
	if _creatures.size() > 0:
		return _creatures.front()
	if _items.size() > 0:
		return _items.front()
	return _tile

func _populate_inspector() -> void:
	populate_creature_tab()
	populate_item_tab()
	populate_tile_tab()
	visible = true

#func _creature_index_changed():
#	var isFirst = creature_index == 0
#	var isLast = creature_index == _creatures.size() -1
#	get_node("Creature/tab_header/creature_selector/prev_creature").disabled = isFirst
#	get_node("Creature/tab_header/creature_selector/next_creature").disabled = isLast
#
#func _item_index_changed():
#	var isFirst = item_index == 0
#	var isLast = item_index == _items.size() -1
#	get_node("Item/tab_header/item_selector/prev_item").disabled = isFirst
#	get_node("Item/tab_header/item_selector/next_item").disabled = isLast

func show_next_creature():
	if creature_index < _creatures.size() -1:
		self.creature_index += 1
	
func show_prev_creature():
	if creature_index > 0:
		self.creature_index -= 1
		
func show_next_item():
	if item_index < _items.size() -1:
		self.item_index += 1
	
func show_prev_item():
	if item_index > 0:
		self.item_index -= 1
	
func populate_creature_tab() -> void:
	if _creatures.size() == 0: 
		set_tab_hidden(TAB_CREATURE, true)
		return
	var creature = _creatures[creature_index]
	if get_tab_hidden(TAB_CREATURE): set_tab_hidden(TAB_CREATURE, false)
	var isFirst = creature_index == 0
	var isLast = creature_index == _creatures.size() -1
	get_node("Creature/tab_header/creature_selector/prev_creature").disabled = isFirst
	get_node("Creature/tab_header/creature_selector/next_creature").disabled = isLast
	get_node("Creature/tab_header/creature_selector/creature_name").text = creature.first_name
	get_node("Creature/creature_data/creature_type/value").text = CreatureType.Type.keys()[creature.type]
	get_node("Creature/creature_data/creature_subtype/value").text = CreatureSubtype.Subtype.keys()[creature.subtype]
	get_node("Creature/creature_data/creature_location/value").text = 'x: %d, y: %d' % [creature.location.x, creature.location.y]
	
func populate_item_tab() -> void:
	if _items.size() == 0:
		set_tab_hidden(TAB_ITEM, true)
		return
	var item = _items[item_index]
	if get_tab_hidden(TAB_ITEM): set_tab_hidden(TAB_ITEM, false)
	var isFirst = item_index == 0
	var isLast = item_index == _items.size() -1
	get_node("Item/tab_header/item_selector/prev_item").disabled = isFirst
	get_node("Item/tab_header/item_selector/next_item").disabled = isLast
	get_node("Item/tab_header/item_selector/item_name").text = item.item_name
	get_node("Item/item_data/item_size/value").text = '%s' % item.size
	get_node("Item/item_data/item_weight/value").text = '%s' % item.weight
	get_node("Item/item_data/item_location/value").text = 'x: %d, y: %d' % [item.location.x, item.location.y]
	
func populate_tile_tab():
	var tile = _tile
	get_node("Tile/col1/tile_location/value").text = 'x: %d, y: %d' % [tile.location.x, tile.location.y]
	get_node("Tile/col1/tile_elevation/value").text = '%s' % tile.elevation
	get_node("Tile/col2/tile_type/value").text = TileType.Type.keys()[tile.tile_type]
	get_node("Tile/col2/tile_soil_quality/value").text = '%s' % tile.soil_quality
	
func _unhandled_input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_ESCAPE:
					if event.is_pressed(): visible = false
				KEY_I:
					if event.is_pressed(): visible = !visible
		'InputEventMouseMotion':
			if _following_mouse && !_selected:
				print(get_viewport().size)
				self._target = _get_target_at_location(SpriteManager.position_to_location(event.position))
		'InputEventMouseButton':
			if event.get_button_index() == BUTTON_LEFT:
				if event.is_pressed():
					self._selected = _get_target_at_location(SpriteManager.position_to_location(event.position))
					
