extends OGEntity
class_name OGItem

var material: int
# TODO: FIGURE OUT HOW VALUE IS MEASURED
var value: int
var edible: bool = false
var nutrition_value: int = 0

var tagged: bool = false
var owned: bool = false


func is_available():
	return !owned and !tagged

func _ready():
	ItemManager.add_to_world(self)

func remove_from_map():
	sprite.queue_free()
	set_location(Global.OFF_MAP)

func get_class(): return 'OGItem'
