extends OGEntity
class_name OGCreature

var type: int
var subtype: int
var first_name: String
var idle_state: int = Creature.IdleState.IDLE

var fullness: int = 0

var inventory: Array = [] setget set_inventory
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

var tagged: Array = [] 
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
		
var owned: Array = [] setget set_owned
func set_owned(val):
	owned = val
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

# TODO: LINK OWNED AND TAGGED SIGNALS TO ITEMMANAGER, IN ORDER TO UPDATE GROUPS

# build_power is how much build_cost is paid toward the construction of a Built per tick
var build_power: float = 1.1

var skills: PoolIntArray = [ Creature.Skill.HAULING, Creature.Skill.BUILDING]

func get_class(): return 'OGCreature'
