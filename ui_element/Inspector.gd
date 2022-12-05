extends TabContainer

var margin: int = 10

enum {
	TAB_CREATURE,
	TAB_TILE,
}

func _init():
	var InspectorTheme = Theme.new()
	InspectorTheme.add_type('HBoxContainer')
	InspectorTheme.set_constant('separation', 'HBoxContainer', 40)
	theme = InspectorTheme
	
func inspect(data: Dictionary) -> void:
#	clear_inspector()
	# data includes tile and list of creatures and list of objects
	if data.creature:
		populate_creature_tab(data.creature)
		set_tab_hidden(TAB_CREATURE, false)
	else:
		set_tab_hidden(TAB_CREATURE, true)
	if data.tile:
		populate_tile_tab(data.tile)
		set_tab_hidden(TAB_TILE, false)
	else:
		set_tab_hidden(TAB_TILE, true)
#	$Tile.visible = true
	visible = true
	
func populate_creature_tab(creature:CreatureModel) -> void:
	get_node("Creature/col1/creature_name/value").text = creature.first_name
	get_node("Creature/col1/creature_type/value").text = CreatureType.Type.keys()[creature.type]
	get_node("Creature/col1/creature_subtype/value").text = CreatureSubtype.Subtype.keys()[creature.subtype]
	get_node("Creature/col2/creature_location/value").text = 'x: %d, y: %d' % [creature.location.x, creature.location.y]
	
func populate_tile_tab(tile: OrcGameMapTile):
	get_node("Tile/col1/tile_location/value").text = 'x: %d, y: %d' % [tile.x, tile.y]
	get_node("Tile/col1/tile_elevation/value").text = '%s' % tile.elevation
	get_node("Tile/col2/tile_type/value").text = TileType.Type.keys()[tile.tile_type]
	get_node("Tile/col2/tile_soil_quality/value").text = '%s' % tile.soil_quality
