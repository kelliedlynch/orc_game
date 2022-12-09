extends Node
class_name GOAPStateTracker

# Every creature will have its own State Tracker. The State Tracker holds all the key-value
# pairs that describe the creature's personal and world state, as well as the logic for
# updating those values.


# when orc has bone, this dictionary contains 'has_bone': true
var _state: Dictionary = {}

# returns true if dictionary contains this key-value pair
func check_state_for(state_name, state_value = null):
	return _state.get(state_name, state_value)
	
# NOTE: currently nothing is watching the state dictionary for changes, so nothing is going to check
# if values are different before setting them. I don't know if this will cause performance issues
# with large populations.
func set_state_for(state_name, state_value):
	_state[state_name] = state_value

