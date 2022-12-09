extends OGEntity
class_name OGCreature

var type: int
var subtype: int
var first_name: String

onready var agent: AIAgent = AIAgent
onready var state_tracker: GOAPStateTracker = $GOAPStateTracker

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

var tagged = [] 
func tag_item(item: OGItem) -> void:
	if !tagged.has(item):
		tagged.append(item)
		item.tagged = true
		emit_signal("creature_tagged_item", self, item, true)
signal creature_tagged_item()
func untag_item(item: OGItem) -> void:
	if tagged.has(item):
		tagged.erase(item)
		item.tagged = false
		emit_signal("creature_tagged_item", self, item, false)


# interval is time in seconds between AI ticks, elapsed is how long since last tick
# This is how fast the creature 'thinks', lower is faster
var interval: float = 0.1
var elapsed: float = 0.0
# The higher the laziness, the longer the creature will remain idle between actions
# This is how fast the creature works
var laziness: float = 0.1
var time_idle: float = 0.0
# higher move_delay means the creature will take longer between move steps
var move_delay: float = 0.1
# higher move_power means the creature can traverse more difficult terrain
# this affects climbing ability, speed over ground obstacles, fall damage
var move_power: float = 0.1

signal inventory_changed()

enum CreatureState {
	IDLE,
	MOVING,
	WORKING,
}

enum CreatureSkill {
	HAULING,
	FARMING,
	FIGHTING,
}

func _init():
	pause_mode = PAUSE_MODE_STOP
	connect('inventory_changed', ItemManager, "inventory_changed")
	connect('creature_tagged_item', ItemManager, "creature_tagged_item")


	
func move_toward_location(loc: Vector2):
	var path = Global.pathfinder.get_path(location, loc)
	if path.empty(): return
	self.location = path[0]
	
func _process(delta):
	elapsed += delta
	if elapsed > interval:
		agent.run(self)
		elapsed = 0
	
	
# TODO: move namegen data out of creature model, as it's not needed after creature generation
		
func generate_first_name() -> String:
	var method2_chance = max(first_name_syllable1.size() - 1, first_name_syllable2.size() - 1)
	var method3_chance = max(first_name_word1.size() - 1, first_name_word2.size() -1)
	var methods = first_name_complete.size() - 1 + method2_chance + method3_chance
	var method = randi() % methods
	var _first: Array
	var _second: Array
	if method < first_name_complete.size():
		return first_name_complete[method]
	elif method >= method2_chance and method < method3_chance:
		_first = first_name_syllable1
		_second = first_name_syllable2
	else:
		_first = first_name_word1
		_second = first_name_word2
	return _first[randi() % (_first.size() - 1)] + _second[randi() % (_second.size() - 1)]
	
# Name generator variables to be set by creature type/subtype
var first_name_complete: Array
var first_name_syllable1: Array
var first_name_syllable2: Array
var first_name_word1: Array
var first_name_word2: Array
