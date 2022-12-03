extends TabContainer
class_name Inspector

var margin: int = 10

const TerrainConstants = preload('res://maps/TerrainConstants.gd')
const CreatureType = preload('res://creatures/CreatureType.gd')

func _init():
	var InspectorTheme = Theme.new()
	InspectorTheme.add_type('HBoxContainer')
	InspectorTheme.set_constant('separation', 'HBoxContainer', 40)
	theme = InspectorTheme
	var _i = connect('hide', self, '_on_hide')

func _ready():
	var x = get_viewport_rect().size.x
	var y = get_viewport_rect().size.y
	rect_size = Vector2(x / 2.5, y / 3)
	set_position(Vector2(x - rect_size.x - margin, y - rect_size.y - margin))
	visible = false
#	print(Theme.new().get_type_list(''))
#	col.set_h_size_flags(SIZE_EXPAND_FILL)
#	add_child(tab)
	
func inspect(data: Dictionary) -> void:
	clear_inspector()
	# data includes tile and list of creatures and list of objects
	if data.creature:
		add_child(build_creature_tab(data.creature))
	add_child(build_tile_tab(data.tile))
	visible = true


func clear_inspector():
	for child in get_children():
		child.queue_free()
		remove_child(child)
	
func two_column_tab(name: String, col1_items: Array, col2_items: Array) -> HBoxContainer:
	var tab = HBoxContainer.new()
	tab.name = name
	var col1 = VBoxContainer.new()
	col1.set_h_size_flags(SIZE_EXPAND_FILL)
	tab.add_child(col1)
	var col2 = VBoxContainer.new()
	col2.set_h_size_flags(SIZE_EXPAND_FILL)
	tab.add_child(col2)
	for item in col1_items:
		col1.add_child(item)
	for item in col2_items:
		col2.add_child(item)
	return tab

func build_creature_tab(creature: CreatureModel) -> HBoxContainer:
	var col1 = ([
		data_table_row('Name', creature.first_name),
		data_table_row('Type', CreatureType.TYPE.keys()[creature.type]),
		data_table_row('Subtype', CreatureType.SUBTYPE.keys()[creature.subtype]),
	])
	var col2 = ([
		data_table_row('Location', 'x: %s, y: %s' % [creature.x, creature.y]),
	])
	var tab = two_column_tab('Creature', col1, col2)
	return tab

func build_tile_tab(tile: OrcGameMapTile) -> HBoxContainer:
	var col1 = ([
		data_table_row('Location', 'x: %s, y: %s' % [tile.x, tile.y]),
		data_table_row('Elevation', '%s' % tile.elevation),
	])
	var col2 = ([
		data_table_row('Tile Type', TerrainConstants.TILE_TYPE.keys()[tile.tile_type]),
		data_table_row('Soil Quality', '%s' % tile.soil_quality),
	])
	var tab = two_column_tab('Tile', col1, col2)
	return tab
	
func _on_hide():
	clear_inspector()

func data_table_row(name: String, value: String) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.set_h_size_flags(SIZE_EXPAND_FILL)
	var name_label = Label.new()
	var value_label = Label.new()
	name_label.text = name
	name_label.set_align(ALIGN_LEFT)
	name_label.set_h_size_flags(SIZE_EXPAND_FILL)
	value_label.text = value
	value_label.set_align(ALIGN_RIGHT)
	value_label.set_h_size_flags(SIZE_EXPAND_FILL)
	container.add_child(name_label)
	container.add_child(value_label)
	return container




