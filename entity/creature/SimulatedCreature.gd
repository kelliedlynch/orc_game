extends Node


var type: int
var subtype: int
var first_name: String

var _inventory = [] setget set_inventory, get_inventory
func set_inventory(val: Array) -> void:
	_inventory = val
	emit_signal("inventory_changed", self)
func get_inventory() -> Array:
	return _inventory
func add_to_inventory(item: OGItem) -> void:
	_inventory.append(item)
	emit_signal("inventory_changed", self)
func remove_from_inventory(item: OGItem) -> void:
	var i = _inventory.find(item)
	_inventory.remove(i)
	emit_signal("inventory_changed", self)
signal inventory_changed()

var tagged = [] 
func tag_item(item: OGItem) -> void:
	if !tagged.has(item):
		tagged.append(item)
		item.tagged = true
func untag_item(item: OGItem) -> void:
	if tagged.has(item):
		tagged.erase(item)
		item.tagged = false
		
var owned = [] 
func own_item(item: OGItem) -> void:
	if !owned.has(item):
		owned.append(item)
		item.owned = true
func unown_item(item: OGItem) -> void:
	if owned.has(item):
		owned.erase(item)
		item.owned = false

# interval is time in seconds between AI ticks, elapsed is how long since last tick
# This is how fast the creature 'thinks', lower is faster
var interval: float = 0.1
var elapsed: float = 0.0
# build_power is how much build_cost is paid toward the construction of a Built per tick
var build_power: float = 1.1


var skills: Array = [ CreatureSkill.HAULING, CreatureSkill.BUILDING]

func _init():
	pause_mode = PAUSE_MODE_STOP
