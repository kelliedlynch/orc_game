extends TileMap
class_name GameWorldMap

const GameMapTile = preload("res://GameMapTile.gd")
var dialog_window = ConfirmationDialog.new()

var map_size = {}
var map_tiles = []

func init_noise(octaves: int = 4, period: float = 20.0, persistence: float = 0.8, lacunarity: float = 2.0):
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	return noise

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
		var x = i % int(map_size.x)
		var tile = GameMapTile.new(x, y)
		
		
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
		
		if tile.elevation < 0:
			tile.type = "ocean"
			continue
		if tile.soil_quality < .4 and tile.precipitation < .4:
			tile.type = "desert"
			continue
		if tile.soil_quality < .36:
			tile.type = "rocky"
			continue
		if tile.soil_quality < .8 and tile.temperature < .5:
			tile.type = "temperate"
			continue
		if tile.temperature > .49:
			tile.type = "lush"
			continue
		tile.type = "unknown"
		
		
			
	prints("Elevation", minEl, maxEl)
	prints("Soil Quality", minSq, maxSq)
	prints("Temperature", minTm, maxTm)
	prints("Precipitation", minPr, maxPr)
	prints("Seismic Activity", minSe, maxSe)
	prints("Wind Intensity", minWi, maxWi)
	
func apply_factor(value, factor):
	if factor == 0 or value == 1 or value == -1:
		return value
	var distance = 1 - abs(value)
	distance -= factor * distance
	if value > 0:
		return 1 - distance
	else:
		return -1 + distance

func draw_map():
	for tile in map_tiles:
		var position = map_to_world(Vector2(tile.location.x, tile.location.y))
		var rect = ColorRect.new()
		rect.set_position(position)
		rect.set_size(cell_size)
		tile.rect = rect
		self.add_child(rect)
	
	color_world_map()

func tile_at(x: int, y: int):
	if x > map_size.x:
		push_error("Coord x:" + str(x) + " out of bounds")
		return null
	if y > map_size.y:
		push_error("Coord y:" + str(y) + " out of bounds")
		return null
	var index = y * map_size.x + x
	return map_tiles[index]

func tiles_adjacent_to(tile: GameMapTile):
	var tiles = []
	if tile.location.x > 0:
		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
		if tile.location.y > 0:
			tiles.append(tile_at(tile.location.x - 1, tile.location.y - 1))
		if tile.location.y < map_size.y - 1:
			tiles.append(tile_at(tile.location.x - 1, tile.location.y + 1))	
	if tile.location.y > 0:
		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
	if tile.location.y < map_size.y - 1:
		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
	if tile.location.x < map_size.x - 1:
		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
		if tile.location.y > 0:
			tiles.append(tile_at(tile.location.x + 1, tile.location.y - 1))
		if tile.location.y < map_size.y - 1:
			tiles.append(tile_at(tile.location.x + 1, tile.location.y + 1))
	return tiles

func tiles_orthogonal_to(tile: GameMapTile):
	var tiles = []
	if tile.location.x > 0:
		tiles.append(tile_at(tile.location.x - 1, tile.location.y))
	if tile.location.x < map_size.x - 1:
		tiles.append(tile_at(tile.location.x + 1, tile.location.y))
	if tile.location.y > 0:
		tiles.append(tile_at(tile.location.x, tile.location.y - 1))
	if tile.location.y < map_size.y - 1:
		tiles.append(tile_at(tile.location.x, tile.location.y + 1))
	return tiles

func tile_is_plate_edge(tile: GameMapTile):
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
		
		if tile.type == "ocean":
			blue = apply_factor(0.7, tile.elevation)
		elif tile.type == "desert":
			green = apply_factor(.75, tile.elevation)
			red = green
		elif tile.type == "rocky":
			red = apply_factor(.5, tile.soil_quality)
			green = red
			blue = red
		elif tile.type == "temperate":
			green = apply_factor(.7, tile.soil_quality)
			blue = .25
			red = .1
		elif tile.type == "lush":
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
	# Initialize random number generator
	randomize()
	
	var vector = self.world_to_map(self.get_viewport_rect().end)
	map_size.x = vector.x
	map_size.y = vector.y
	create_tiles()
	draw_map()
	
func _draw():
	pass

	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var target_location = world_to_map(event.position)
#		var tile = tile_at(target_location.x, target_location.y)
		if !dialog_window.visible:
			dialog_window.window_title = "window title"
			dialog_window.dialog_text = "dialog text"
			self.add_child(dialog_window)
			dialog_window.popup_centered()
			dialog_window.get_ok().connect('button_up', self, '_on_confirm_enter_region')
			dialog_window.get_cancel().connect("button_up", self, '_on_cancel_dialog_window')
		
		
func _on_confirm_enter_region():
#	dialog_window.hide()
	self.remove_child(dialog_window)
	print("new region")

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
