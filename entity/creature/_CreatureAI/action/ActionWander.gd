extends GOAPAction
class_name ActionWander


func is_valid(_query: Dictionary) -> bool:
	return true

# Things that must be true for this Action to be considered
# These are not compared against a simulated state--for purposes of planning, these are not things
# that creature actions can affect
func requirements(conditions: Dictionary = {}) -> Dictionary:
	# CREATURE MUST BE MOBILE

	return conditions

# The conditions that activate the Action
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			'idle_state': Creature.IdleState.IDLE
		}
	}
	return conditions

# The outcome of the Action
# Action never actually changes the idle state, but still seeks the PLAYING state.
# This way, the action will be performed endlessly until another, better action becomes available
func applied_transform(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			'idle_state': Creature.IdleState.PLAYING
		}
	}
	return conditions
	
func perform(actor):
	var valid = CreatureManager.map.locations_adjacent_to(actor.location)
	var i = randi() % valid.size()
	actor.set_location(valid[i])
	return false
