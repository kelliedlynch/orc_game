extends OrcGameMap
class_name WorldMap

var map_layer: WorldMapLayer

signal generated_map_tiles()

func _init():
	print('WorldMap init')
	
func _ready():
	map_layer = get_node('WorldMapLayer')
	var tiles = WorldData.world_map_tiles
	if tiles.size() > 0:
		load_map_from_tiles(tiles)
	else:
		generate_map_tiles()

func generate_map_tiles() -> void:
	var terrain_intensity_noise = init_noise(1, 8.5, 1, 4)
	var soil_quality_noise = init_noise()
	var temp_band_noise = init_noise(1, 60, 0.3, 20.0)
	var elevation_noise = init_noise(3, 62, 0.75, 2.76)
	var wind_noise = init_noise(2, 10, 0.5, 2.0)
	var precipitation_noise = init_noise(4, 30, 0.5, 2)
	
	# Create tiles and make first pass of tile properties.
	# Properties without dependencies: continental plates, soil quality, wind intensity, temperature band
	for i in range(width * height):
		var y = floor(i / float(width))
		var x = i % width
		var tile = WorldMapTile.new(x, y)
		
		tile.terrain_intensity = max(min((apply_factor((terrain_intensity_noise.get_noise_2d(tile.x, tile.y)) - .4, 0.4)) + 0.25, 1), -1)
		tile.soil_quality = soil_quality_noise.get_noise_2d(tile.x, tile.y)
		tile.temperature = temp_band_noise.get_noise_2d(tile.x, tile.y)
		tile.wind_intensity = wind_noise.get_noise_2d(tile.x, tile.y)
		tile.precipitation = precipitation_noise.get_noise_2d(tile.x, tile.y)
		tile.elevation = max(min(apply_factor(elevation_noise.get_noise_2d(tile.x, tile.y), -0.35) + 0.27, 1), -1)
		map_tiles.append(tile)
		
	# Second pass of tile properties.
	# Adjust elevation based on seismic activity
	# Adjust temperature based on wind speed
		tile.elevation = apply_factor(tile.elevation, tile.terrain_intensity * .8)
		tile.temperature = apply_factor(tile.temperature, -tile.wind_intensity * .25)
			
	# Third pass of tile properties.
	# Adjust temperature based on elevation
		if tile.elevation > 0.2:
			tile.temperature = apply_factor(tile.temperature, -tile.elevation)
		if tile.elevation < -0.2:
			tile.temperature = apply_factor(tile.temperature, tile.elevation * .25)
			
	# Find terrain type of each tile based on its properties.
		var possible_regions = []
		for region_type in TerrainConstants.REGION_PARAMETERS:
			var region_parameters = TerrainConstants.REGION_PARAMETERS[region_type]['generation_parameters']
			for p_name in region_parameters:
				var param_name = p_name.substr(4)
				if p_name.begins_with('min'):
					if tile[param_name] < region_parameters[p_name]:
						continue
				elif p_name.begins_with('max'):
					if tile[param_name] > region_parameters[p_name]:
						continue
				possible_regions.append(region_type)
				
		tile.region_type = possible_regions[0]
#	print(get_min_max())
	emit_signal("generated_map_tiles")

func load_map_from_tiles(tiles: Array):
	map_tiles = tiles
		
func get_min_max():
	var maxEl = map_tiles[0].elevation; var minEl = maxEl
	var maxSq = map_tiles[0].soil_quality; var minSq = maxSq
	var maxTm = map_tiles[0].temperature; var minTm = maxTm
	var maxPr = map_tiles[0].precipitation; var minPr = maxPr
	var maxTe = map_tiles[0].terrain_intensity; var minTe = maxTe
	var maxWi = map_tiles[0].wind_intensity; var minWi = maxWi
	
	for tile in map_tiles:
		if tile.elevation > maxEl:
			maxEl = tile.elevation
		if tile.elevation < minEl:
			minEl = tile.elevation
		if tile.soil_quality > maxSq:
			maxSq = tile.soil_quality
		if tile.soil_quality < minSq:
			minSq = tile.soil_quality
		if tile.temperature > maxTm:
			maxTm = tile.temperature
		if tile.temperature < minTm:
			minTm = tile.temperature
		if tile.precipitation > maxPr:
			maxPr = tile.precipitation
		if tile.precipitation < minPr:
			minPr = tile.precipitation
		if tile.terrain_intensity > maxTe:
			maxTe = tile.terrain_intensity
		if tile.terrain_intensity < minTe:
			minTe = tile.terrain_intensity
		if tile.wind_intensity > maxWi:
			maxWi = tile.wind_intensity
		if tile.wind_intensity < minWi:
			minWi = tile.wind_intensity
			
	return {
		'minEl': minEl,
		'maxEl': maxEl,
		'minSq': minSq,
		'maxSq': maxSq,
		'minTm': minTm,
		'maxTm': maxTm,
		'minPr': minPr,
		'maxPr': maxPr,
		'minTe': minTe,
		'maxTe': maxTe,
		'minWi': minWi,
		'maxWi': maxWi,
	}

func color_property_map(property: String):
	var colors = []
	for tile in map_tiles:
		var value = (tile.get(property) + 1) / 2
		colors.append(Color(value, value, value, 1))
	map_layer.color_tiles(colors)
		
func _on_ShowPlates_toggled(button_pressed):
	if button_pressed:
		color_property_map('terrain_intensity')
	else:
		map_layer.set_base_colors()

func _on_ShowElevation_toggled(button_pressed):
	if button_pressed:
		color_property_map('elevation')
	else:
		map_layer.set_base_colors()

func _on_ShowTemperature_toggled(button_pressed):
	if button_pressed:
		color_property_map('temperature')
	else:
		map_layer.set_base_colors()

func _on_ShowWind_toggled(button_pressed):
	if button_pressed:
		color_property_map('wind_intensity')
	else:
		map_layer.set_base_colors()

func _on_ShowPrecipitation_toggled(button_pressed):
	if button_pressed:
		color_property_map('precipitation')
	else:
		map_layer.set_base_colors()
