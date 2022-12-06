# Testing ground for creatures, allows spawning of new creatures
extends RegionMapScene
class_name CreatureTestingGround

var placing_item = false

func _init():
	pass

func _ready():
	var default_tile = OrcGameMapTile.new(1, 1)
	create_region_from_tile(default_tile)
# warning-ignore:return_value_discarded
	connect('picked_bone_location', self, 'place_bone_at_location')

signal picked_bone_location()

func place_bone_at_location(loc: Vector2):
	var bone = OGItemBone.new()
	add_child(bone)
	bone.location = loc
	placing_item = false

func _on_SpawnNewBone_button_up():

	# There is currently (12/5/22) a bug preventing use of .tres as mouse cursor.
	# png workaround for now
	var png = load('res://entity/item/og_item_bone.png')
	Input.set_custom_mouse_cursor(png)
	placing_item = true
	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if placing_item:
					emit_signal("picked_bone_location", Global.position_to_location(event.global_position))
				show_inspector(event.position)
