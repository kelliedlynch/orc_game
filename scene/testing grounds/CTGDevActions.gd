extends CanvasLayer

#var placing_item = false
#
#func _ready():
#	connect('picked_bone_location', self, 'place_bone_at_location')
#
#signal picked_bone_location()
#
#func place_bone_at_location(loc: Vector2):
#	var bone = preload("res://entity/item/OGItemBone.tscn").instance()
#	bone.location = loc
#	add_child(bone)
#	placing_item = false
#
#func _on_SpawnNewOrc_button_up():
#	var orc = preload("res://entity/creature/orc/OGCreatureOrc.tscn").instance()
#	orc.location = Vector2(32, 17)
#	add_child(orc)
#
#func _on_SpawnNewBone_button_up():
#	# There is currently (12/5/22) a bug preventing use of .tres as mouse cursor.
#	# png workaround for now
##	var png = load('res://asset/sprite/og_item_bone.png')
##	Input.set_custom_mouse_cursor(png)
#	placing_item = true
#
##func _input(event):
##	pass
##
##func _gui_input(event):
##	pass
#
#func _input(event):
#	match event.get_class():
#		"InputEventMouseButton":
#			if event.is_pressed():
#				if event.button_index == BUTTON_LEFT:
#					if placing_item:
#						get_tree().set_input_as_handled()
#						emit_signal("picked_bone_location", SpriteManager.position_to_location(event.global_position))
