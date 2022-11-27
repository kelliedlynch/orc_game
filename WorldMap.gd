extends "res://OrcGameMap.gd"
class_name WorldMap

const WorldMapTile = preload("res://WorldMapTile.gd")
const RegionMapScene = preload('res://RegionMapScene.gd')
var dialog_window = ConfirmationDialog.new()

func create_tiles():
	var continental_plate_noise = init_noise(4, 40.0, 0.2, 4.0)
	var soil_quality_noise = init_noise()
	var temp_band_noise = init_noise(1, 60, 0.3, 20.0)
	var elevation_noise = init_noise(3, 20, 0.18, 6.0)
	var wind_noise = init_noise(2, 10, 0.5, 2.0)
	var precipitation_noise = init_noise(4, 30, 0.5, 2)
	
	# Create tiles and make first pass of tile properties.
	# Properties without dependencies: continental plates, soil quality, wind intensity, temperature band
	var number_of_plates = (randi() % 3) + 3
	for i in range(map_size.x * map_size.y):
		var y = floor(i / map_size.x)
		var x = i % map_size.x
		var tile = WorldMapTile.new(x, y)
		
		tile.plateId = floor(abs(continental_plate_noise.get_noise_2d(tile.location.x, tile.location.y)) * number_of_plates)
		tile.soil_quality = (soil_quality_noise.get_noise_2d(tile.location.x, tile.location.y) + 1.0) / 2.0
		tile.temperature = temp_band_noise.get_noise_2d(tile.location.x, tile.location.y)
		tile.wind_intensity = (wind_noise.get_noise_2d(tile.location.x, tile.location.y) + 1.0) / 2.0
		tile.precipitation = (precipitation_noise.get_noise_2d(tile.location.x, tile.location.y) + 1.0) / 2.0
		tile.elevation = elevation_noise.get_noise_2d(tile.location.x, tile.location.y)
		map_tiles.append(tile)
		
	# Second pass of tile properties.
	# Mark plate edges (seismic activity)
	# Adjust elevation based on seismic activity
	# Adjust temperature based on wind speed
	for tile in map_tiles:
		if tile_is_plate_edge(tile) == true:
			tile.seismic_activity = (randi() % 80 + 21) / 100.0
		else:
			tile.seismic_activity = (randi() % 30) / 100.0
		tile.elevation = apply_factor(tile.elevation, tile.seismic_activity * .65)
		tile.temperature = apply_factor(tile.temperature, -tile.wind_intensity * .25)
			
	# Third pass of tile properties.
	# Adjust temperature based on elevation
	for tile in map_tiles:
		if tile.elevation > 0.2:
			tile.temperature = apply_factor(tile.temperature, -tile.elevation)
		if tile.elevation < -0.2:
			tile.temperature = apply_factor(tile.temperature, tile.elevation * .25)
			
	# Find terrain type of each tile based on its properties.
		if tile.elevation < 0:
			tile.region_type = "ocean"
			continue
		if tile.soil_quality < .4 and tile.precipitation < .4:
			tile.region_type = "desert"
			continue
		if tile.soil_quality < .36:
			tile.region_type = "rocky"
			continue
		if tile.soil_quality < .8 and tile.temperature < .5:
			tile.region_type = "temperate"
			continue
		if tile.temperature > .49:
			tile.region_type = "lush"
			continue
		tile.region_type = "unknown"
		
#	var minMax = get_min_max()
#	prints("Elevation", minMax.minEl, minMax.maxEl)
#	prints("Soil Quality",minMax.minSq, minMax.maxSq)
#	prints("Temperature", minMax.minTm, minMax.maxTm)
#	prints("Precipitation", minMax.minPr, minMax.maxPr)
#	prints("Seismic Activity", minMax.minSe, minMax.maxSe)
#	prints("Wind Intensity", minMax.minWi, minMax.maxWi)
	pass
	
func get_min_max():
	var maxEl = map_tiles[0].elevation; var minEl = maxEl
	var maxSq = map_tiles[0].soil_quality; var minSq = maxSq
	var maxTm = map_tiles[0].temperature; var minTm = maxTm
	var maxPr = map_tiles[0].precipitation; var minPr = maxPr
	var maxSe = map_tiles[0].seismic_activity; var minSe = maxSe
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
		if tile.seismic_activity > maxSe:
			maxSe = tile.seismic_activity
		if tile.seismic_activity < minSe:
			minSe = tile.seismic_activity
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
		'minSe': minSe,
		'maxSe': maxSe,
		'minWi': minWi,
		'maxWi': maxWi,
	}
	
func apply_factor(value, factor):
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	if value > 0:
		return 1 - distance
	else:
		return -1 + distance

func tile_is_plate_edge(tile: WorldMapTile):
	for adj in tiles_adjacent_to(tile):
		if adj.plateId != tile.plateId:
			return true
	return false

func color_continental_plate_borders():
	for tile in map_tiles:
		var red = 0
		if tile_is_plate_edge(tile):
			red = 1.0
		var tile_color = Color(red, 0, 0, 1)
		tile.rect.color = tile_color

func color_elevation_map():
	for tile in map_tiles:
		var value = (tile.elevation + 1) / 2
		tile.rect.color = Color(value, value, value, 1)

func color_temperature_map():
	for tile in map_tiles:
		var red = (tile.temperature + 1) / 2
		var blue = 1 - red
		var color = Color(red, 0.2, blue, 1.0)
		tile.rect.color = color
		
func color_wind_map():
	for tile in map_tiles:
		var value = tile.wind_intensity
		tile.rect.color = Color(value, value, value, 1)
		
func color_precipitation_map():
	for tile in map_tiles:
		var value = tile.precipitation
		tile.rect.color = Color(0.2, value * .75, value)
		
func color_world_map():
	for tile in map_tiles:
		var red = 0
		var green = 0
		var blue = 0
		var alpha = 1
		
		if tile.region_type == "ocean":
			blue = apply_factor(0.7, tile.elevation)
		elif tile.region_type == "desert":
			green = apply_factor(.75, tile.elevation)
			red = green
		elif tile.region_type == "rocky":
			red = apply_factor(.5, tile.soil_quality)
			green = red
			blue = red
		elif tile.region_type == "temperate":
			green = apply_factor(.7, tile.soil_quality)
			blue = .25
			red = .1
		elif tile.region_type == "lush":
			green = apply_factor(.55, tile.soil_quality * .5)
			blue = apply_factor(.4, tile.precipitation * .25)
		else:
			red = 1
			green = red
			blue = red
		
		var color = Color(red, green, blue, alpha)
		tile.rect.color = color
	
# Called when the node enters the scene tree for the first time.
func _ready():
	create_tiles()
	draw_map()
	color_world_map()
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var target_location = world_to_map(event.position)
		var tile = tile_at(target_location.x, target_location.y)
		if !dialog_window.visible:
			dialog_window.window_title = "window title"
			dialog_window.dialog_text = "dialog text"
			self.add_child(dialog_window)
			dialog_window.popup_centered()
			dialog_window.get_ok().connect('button_up', self.get_parent(), '_on_confirm_enter_region', [tile])
			dialog_window.get_cancel().connect("button_up", self, '_on_cancel_dialog_window')
#			get_tree().set_input_as_handled()
		
		
func _on_confirm_enter_region(tile: WorldMapTile):
#	dialog_window.hide()
	remove_child(dialog_window)


#	get_tree().change_scene('res://RegionMapScene')

func _on_cancel_dialog_window():
	self.remove_child(dialog_window)
		
func _on_ShowPlates_toggled(button_pressed):
	if button_pressed:
		color_continental_plate_borders()
	else:
		color_world_map()

func _on_ShowElevation_toggled(button_pressed):
	if button_pressed:
		color_elevation_map()
	else:
		color_world_map()

func _on_ShowTemperature_toggled(button_pressed):
	if button_pressed:
		color_temperature_map()
	else:
		color_world_map()


func _on_ShowWind_toggled(button_pressed):
	if button_pressed:
		color_wind_map()
	else:
		color_world_map()


func _on_ShowPrecipitation_toggled(button_pressed):
	if button_pressed:
		color_precipitation_map()
	else:
		color_world_map()


func _on_NewWorld_button_up():
	for tile in map_tiles:
		tile.rect.queue_free()
		tile.queue_free()
	map_tiles = []
	create_tiles()
	draw_map()
