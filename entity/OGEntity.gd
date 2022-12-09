#
# ENTITY CONVENTIONS TO REMEMBER
# 'position' means position in viewport or global
# 'location' means grid location in map

extends Node
class_name OGEntity

var location: Vector2 = Vector2.ZERO setget set_location
var sprite: Sprite
var held_by_player: bool = false

# Size and weight range from 0 to 1
var size: float
var weight: float

signal location_changed()

func _ready():
	connect("location_changed", EntityManager, "_location_changed")
	connect("location_changed", SpriteManager, "entity_location_changed")
	sprite = $EntitySprite
	emit_signal("location_changed", self, location)
	
func set_location(val: Vector2):
	var oldval = location
	location = val
	emit_signal('location_changed', self, location, oldval)


