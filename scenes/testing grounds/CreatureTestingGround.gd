# Testing ground for creatures, allows spawning of new creatures
# Assign script to a RegionMapScene to use

extends RegionMapScene

func _init():
	pass

func _ready():
	var default_tile = WorldMapTile.new(1, 1)
	create_region_from_tile(default_tile)

#func create_spawn_button():
#	var button = Button.new()
#	button.text = 'Spawn New Orc'
#	button.connect("button_up", self, '_spawn_new_orc')
#	button.set_position(Vector2(10, 10))
#	button.set_focus_mode(Control.FOCUS_NONE)	
#	region_map.add_child(button)
