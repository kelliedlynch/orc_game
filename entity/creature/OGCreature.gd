extends OGEntity
class_name OGCreature

var type: int
var subtype: int
var first_name: String
var idle_state: int = Creature.IdleState.IDLE



var inventory = [] setget set_inventory
func set_inventory(val: Array) -> void:
	inventory = val
	emit_signal("inventory_changed", self)
func get_inventory() -> Array:
	return inventory
func add_to_inventory(item: OGItem) -> void:
	inventory.append(item)
	emit_signal("inventory_changed", self)
func remove_from_inventory(item: OGItem) -> void:
	var i = inventory.find(item)
	inventory.remove(i)
	emit_signal("inventory_changed", self)
signal inventory_changed()

var tagged = [] 
func tag_item(item: OGItem) -> void:
	if !tagged.has(item):
		tagged.append(item)
		item.tagged = true
		emit_signal("creature_tagged_item", self, item, true)
func untag_item(item: OGItem) -> void:
	if tagged.has(item):
		tagged.erase(item)
		item.tagged = false
		emit_signal("creature_tagged_item", self, item, false)
signal creature_tagged_item()
		
var owned = [] 
func own_item(item: OGItem) -> void:
	if !owned.has(item):
		owned.append(item)
		item.owned = true
		emit_signal("creature_owned_item", self, item, true)
func unown_item(item: OGItem) -> void:
	if owned.has(item):
		owned.erase(item)
		item.owned = false
		emit_signal("creature_owned_item", self, item, false)
signal creature_owned_item()

# interval is time in seconds between AI ticks, elapsed is how long since last tick
# This is how fast the creature 'thinks', lower is faster
var interval: float = 0.1
var elapsed: float = 0.0
# build_power is how much build_cost is paid toward the construction of a Built per tick
var build_power: float = 1.1


var skills: PoolIntArray = [ Creature.Skill.HAULING, Creature.Skill.BUILDING]

func _init():
	pause_mode = PAUSE_MODE_STOP

func move_toward_location(loc: Vector2):
	var path = Global.pathfinder.get_path(location, loc)
	if path.empty(): return
	self.location = path[0]
	
func _process(delta):
	elapsed += delta
	if elapsed > interval:
		_run_agent()
		elapsed = 0

func _run_agent():
	pass
	
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
