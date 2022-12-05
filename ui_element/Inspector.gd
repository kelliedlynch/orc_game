extends TabContainer

enum {
	TAB_CREATURE,
	TAB_TILE,
}

var creature_index: int setget _set_creature_index
var item_index: int setget _set_item_index
var creatures: Array = []
var items: Array = []

func _set_creature_index(val: int):
	creature_index = val
	emit_signal('creature_index_changed')
signal creature_index_changed()

func _set_item_index(val: int):
	item_index = val
	emit_signal('item_index_changed')
signal item_index_changed()

func _ready():
	connect("creature_index_changed", self, '_creature_index_changed')
	connect("item_index_changed", self, '_item_index_changed')
	pass

func inspect_tile(tile: OrcGameMapTile) -> void:
	creatures = []
	items = []
	for entity in tile.entities:
		if entity is CreatureModel:
			creatures.append(entity)
		elif entity is ItemModel:
			items.append(entity)
			
	if creatures.size() > 0:
		populate_creature_tab()
		self.creature_index = 0
	set_tab_hidden(2, !(creatures.size() > 0))
		
	if items.size() > 0:
		populate_item_tab()
		self.item_index = 0
	set_tab_hidden(1, !(items.size() > 0))
	set_tab_hidden(0, false)
		
	populate_tile_tab(tile)
	visible = true

func _creature_index_changed():
	var isFirst = creature_index == 0
	var isLast = creature_index == creatures.size() -1
	get_node("Creature/tab_header/creature_selector/prev_creature").disabled = isFirst
	get_node("Creature/tab_header/creature_selector/next_creature").disabled = isLast
	populate_creature_tab()
	
func _item_index_changed():
	var isFirst = item_index == 0
	var isLast = item_index == items.size() -1
	get_node("Item/tab_header/item_selector/prev_item").disabled = isFirst
	get_node("Item/tab_header/item_selector/next_item").disabled = isLast
	populate_item_tab()

func show_next_creature():
	if creature_index < creatures.size() -1:
		self.creature_index += 1
	
func show_prev_creature():
	if creature_index > 0:
		self.creature_index -= 1
		
func show_next_item():
	if item_index < items.size() -1:
		self.item_index += 1
	
func show_prev_item():
	if item_index > 0:
		self.item_index -= 1
	
func populate_creature_tab() -> void:
	var creature = creatures[creature_index]
	get_node("Creature/tab_header/creature_selector/creature_name").text = creature.first_name
	get_node("Creature/creature_data/creature_type/value").text = CreatureType.Type.keys()[creature.type]
	get_node("Creature/creature_data/creature_subtype/value").text = CreatureSubtype.Subtype.keys()[creature.subtype]
	get_node("Creature/creature_data/creature_location/value").text = 'x: %d, y: %d' % [creature.location.x, creature.location.y]
	
func populate_item_tab() -> void:
	var item = items[item_index]
	get_node("Item/tab_header/item_selector/item_name").text = item.item_name
	get_node("Item/item_data/item_size/value").text = '%s' % item.size
	get_node("Item/item_data/item_weight/value").text = '%s' % item.weight
	get_node("Item/item_data/item_location/value").text = 'x: %d, y: %d' % [item.location.x, item.location.y]
#	emit_signal("creature_tab_index_changed", [creature_index == 0, creature_index == creatures.size() - 1])
	
func populate_tile_tab(tile: OrcGameMapTile):
	get_node("Tile/col1/tile_location/value").text = 'x: %d, y: %d' % [tile.x, tile.y]
	get_node("Tile/col1/tile_elevation/value").text = '%s' % tile.elevation
	get_node("Tile/col2/tile_type/value").text = TileType.Type.keys()[tile.tile_type]
	get_node("Tile/col2/tile_soil_quality/value").text = '%s' % tile.soil_quality
	
func _input(event):
	match event.get_class():
		'InputEventKey':
			match event.get_scancode():
				KEY_ESCAPE:
					if event.is_pressed(): visible = false
