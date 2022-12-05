#
# ENTITY CONVENTIONS TO REMEMBER
# 'position' means position in viewport or global
# 'location' means grid location in map

extends Node
class_name EntityModel

var location: Vector2 setget set_location
	
var body: EntityBody
var held_by_player: bool = false

# Size and weight range from 0 to 1
var size: float
var weight: float

signal location_changed()


func _init():
	print('EntityModel init')
	self.connect('location_changed', self, 'place_at_location')
	
func _ready():
	body = EntityBody.new()
	add_child(body)
	
func set_location(val: Vector2):
	location = val
	emit_signal('location_changed', location)

func location_to_position(loc: Vector2):
	return loc * Global.tile_size
	
func position_to_location(pos: Vector2):
	var x = floor(pos.x / Global.tile_size.x)
	var y = floor(pos.y / Global.tile_size.y)
	return Vector2(x, y)

func place_at_location(loc: Vector2):
	body.place_at_position(location_to_position(loc))

#func place_at_position(position: Vector2) -> void:
#	var viewport_position = get_tree().current_scene.grid_to_viewport(position.x, position.y)
#	body.move_to_coords(viewport_position)

func _input(event):
	match event.get_class():
		'InputEventMouseButton':
			if held_by_player:
				emit_signal('item_placed', get_parent(), event.global_position)
				held_by_player = false
		'InputEventMouseMotion':
			if held_by_player:
				body.place_at_position(body.get_global_mouse_position() - body.sprite_size / 2)
