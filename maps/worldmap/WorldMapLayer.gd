extends OrcGameMapLayer
class_name WorldMapLayer

var rect_tiles: Array = []

func _init():
	pass
	
func _enter_tree():
	pass
	
func _ready():
#	set_deferred('rect_tiles', call('generate_rect_tiles'))
	var error_code = get_parent().connect('generated_map_tiles', self, 'generate_rect_tiles')
	if error_code != 0: push_error('ERROR: %d' % error_code)
#	call_deferred('set_base_colors')
	
func generate_rect_tiles():
	if rect_tiles.size() == 0:
		for tile in get_parent().map_tiles:
			var position = map_to_world(Vector2(tile.x, tile.y))
			var rect = ColorRect.new()
			rect.set_position(position)
			rect.set_size(cell_size)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect_tiles.append(rect)
			add_child(rect)
	set_base_colors()
	
func set_base_colors():
	var tiles = get_parent().map_tiles
	var tile_colors: Array = []
	for tile in tiles:
		var red = 0
		var green = 0
		var blue = 0
		var alpha = 1
		
		if tile.region_type == TerrainConstants.REGION_TYPE.OCEAN:
			blue = apply_factor(0.7, tile.elevation)
		elif tile.region_type == TerrainConstants.REGION_TYPE.DESERT:
			green = apply_factor(.75, tile.elevation)
			red = green
		elif tile.region_type == TerrainConstants.REGION_TYPE.ROCKY:
			red = apply_factor(.5, tile.soil_quality)
			green = red
			blue = red
		elif tile.region_type == TerrainConstants.REGION_TYPE.TEMPERATE:
			green = apply_factor(.7, tile.soil_quality)
			blue = .25
			red = .1
		elif tile.region_type == TerrainConstants.REGION_TYPE.JUNGLE:
			green = apply_factor(.55, tile.soil_quality * .5)
			blue = apply_factor(.4, tile.precipitation * .25)
		else:
			red = 1
			green = red
			blue = red
		tile_colors.append(Color(red, green, blue, alpha))
	color_tiles(tile_colors)
	
func color_tiles(colors: Array):
	var index = 0
	for color in colors:
		rect_tiles[index].set_frame_color(colors[index])
		index += 1	

#	for tile in tiles:
#		var position = map_to_viewport(Vector2(tile.x, tile.y))
#		var rect = ColorRect.new()
#		rect.set_position(position)
#		rect.set_size(cell_size)
#		tile.rect = rect
#		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
#		self.add_child(rect)
