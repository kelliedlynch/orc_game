#
# ENTITY CONVENTIONS TO REMEMBER
# 'position' means position in viewport or global
# 'location' means grid location in map

extends Node
class_name OGEntity

var location: Vector2 = Global.OFF_MAP setget set_location
var sprite: Sprite
var held_by_player: bool = false

# Size and weight range from 0 to 1
var size: float
var weight: float

# entity_name is the base name for any entity of this type
# other names can be changed or overwritten, but a Bone will always
# be a Bone
var entity_name: String = 'Entity'
var instance_name: String = 'Entity'

signal location_changed()

func _ready():
	connect("location_changed", EntityManager, "_location_changed")
	connect("location_changed", SpriteManager, "entity_location_changed")
	sprite = $EntitySprite
	emit_signal("location_changed", self, location)
	
func set_location(val):
	var oldval = location
	location = val
	emit_signal('location_changed', self, location, oldval)


func get_class(): return 'OGEntity'
