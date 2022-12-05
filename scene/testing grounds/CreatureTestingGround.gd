# Testing ground for creatures, allows spawning of new creatures
extends RegionMapScene
class_name CreatureTestingGround

func _init():
	pass

func _ready():
	var default_tile = OrcGameMapTile.new(1, 1)
	create_region_from_tile(default_tile)
	


#func create_spawn_button():
#	var button = Button.new()
#	button.text = 'Spawn New Orc'
#	button.connect("button_up", self, '_spawn_new_orc')
#	button.set_position(Vector2(10, 10))
#	button.set_focus_mode(Control.FOCUS_NONE)	
#	region_map.add_child(button)


func _on_SpawnNewBone_button_up():
	var bone = OGItemBone.new()
	add_child(bone)
	bone.held_by_player = true

	
#	print('setting cursor')
#	var png = load('res://items/og_item_bone.png')
#	var atlas = preload('res://items/bone.tres')
#	var orc = preload('res://creatures/orcs/orc_01.tres')
#	Input.set_custom_mouse_cursor(png)
