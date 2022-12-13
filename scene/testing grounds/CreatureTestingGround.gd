# Testing ground for creatures, allows spawning of new creatures
extends RegionMapController
class_name CreatureTestingGround

var placing_entity = null

func _ready():
	connect('picked_entity_location', self, 'place_entity_at_location')

signal picked_entity_location()

func place_entity_at_location(loc: Vector2):
	placing_entity.location = loc
	add_child(placing_entity)
	placing_entity = null
	
func _on_SpawnNewOrc_button_up():
	var orc = preload("res://entity/creature/orc/OGCreatureOrc.tscn").instance()
	orc.location = Vector2(32, 17)
	add_child(orc)

func _on_SpawnNewBone_button_up():
	placing_entity = preload("res://entity/item/OGItemBone.tscn").instance()

func _on_PlaceCampfire_button_up():
	placing_entity = preload('res://entity/built/campfire/OGBuiltCampfire.tscn').instance()

func _input(event):
	match event.get_class():
		"InputEventMouseButton":
			if event.is_pressed():
				if event.button_index == BUTTON_LEFT:
					if placing_entity:
						get_tree().set_input_as_handled()
						emit_signal("picked_entity_location", SpriteManager.position_to_location(event.global_position))
