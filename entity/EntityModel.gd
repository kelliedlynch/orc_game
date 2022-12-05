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
	connect("location_changed", EntityManager, '_entity_location_changed')
#	connect("location_changed", self, '_location_changed')
	pass
	
func _ready():
	add_to_group('entities')
	body = EntityBody.new()
	add_child(body)
	connect("location_changed", body, '_location_changed')
	# position_changed should only be used when the entity is not on a tile, e.g. when
	# being held by the player
	connect("position_changed", body, '_position_changed')
	
func _set_location(val: Vector2):
	var oldval = location
	location = val
	emit_signal('location_changed', self, location, oldval)

func position_to_location(pos: Vector2):
	var x = floor(pos.x / Global.tile_size.x)
	var y = floor(pos.y / Global.tile_size.y)
	return Vector2(x, y)

#func place_at_location(loc: Vector2):
#	print('place_at_location')
#
#	body.place_at_position(location_to_position(loc))

#func place_at_position(position: Vector2) -> void:
#	var viewport_position = get_tree().current_scene.grid_to_viewport(position.x, position.y)
#	body.move_to_coords(viewport_position)

func _input(event):
	match event.get_class():
		'InputEventMouseButton':
			if held_by_player:
				self.location = position_to_location(event.global_position)
				held_by_player = false
		'InputEventMouseMotion':
			if held_by_player:
				var pos = body.get_global_mouse_position() - body.sprite_size / 2
				emit_signal('position_changed', pos)
#				body.place_at_position(body.get_global_mouse_position() - body.sprite_size / 2)
