#
# ENTITY CONVENTIONS TO REMEMBER
# 'position' means position in viewport or global
# 'location' means grid location in map

extends Node
class_name EntityModel

var location: Vector2 = Vector2(-1, -1) setget _set_location
	
var body: EntityBody
var held_by_player: bool = false

# Size and weight range from 0 to 1
var size: float
var weight: float

signal location_changed()
signal position_changed()

func _init():
	
# warning-ignore:return_value_discarded
	connect("location_changed", EntityManager, '_entity_location_changed')
	
func _ready():
	add_to_group('entities')
	body = EntityBody.new()
	add_child(body)
# warning-ignore:return_value_discarded
	connect("location_changed", body, '_location_changed')
	# position_changed should only be used when the entity is not on a tile, e.g. when
	# being held by the player
# warning-ignore:return_value_discarded
	connect("position_changed", body, '_position_changed')
	
func _set_location(val: Vector2):
	var oldval = location
	location = val
	emit_signal('location_changed', self, location, oldval)

func _input(event):
	match event.get_class():
		'InputEventMouseButton':
			if held_by_player:
				self.location = Global.position_to_location(event.global_position)
				held_by_player = false
		'InputEventMouseMotion':
			if held_by_player:
				var pos = body.get_global_mouse_position() - body.sprite_size / 2
				emit_signal('position_changed', pos)
#				body.place_at_position(body.get_global_mouse_position() - body.sprite_size / 2)
