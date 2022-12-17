extends Node
class_name GOAPStateTracker

# Every creature will have its own State Tracker. 
# The State Tracker tracks the creature's state, possible goals, current goal, possible actions,
# current plan, and current step in the plan
var actor: OGCreature
var actions: Array
var goals: Array
var skills: PoolIntArray
var current_goal
var current_plan: Array = []
var current_plan_step = 0
var current_job = null

# when orc has bone, this dictionary contains 'has_bone': true
var _state: Dictionary = {} setget , get_state

func get_state():
	return _state
	
# returns true if dictionary contains this key-value pair
func check_state_for(state_name, state_value = null):
	return _state.get(state_name, state_value)
	
# NOTE: currently nothing is watching the state dictionary for changes, so nothing is going to check
# if values are different before setting them. I don't know if this will cause performance issues
# with large populations.
func set_state_for(state_name, state_value):
	_state[state_name] = state_value
	
func stop_tracking_state(state_name: String):
	_state.erase(state_name)

func add_goals(new_goals: Array):
	for goal in new_goals:
		goal.assign_to_creature(actor)
		goals.append(goal)
		add_child(goal)
	
func add_actions(new_actions: Array):
	actions.append_array(new_actions)

func add_skills(new_skills: Array):
	skills.append_array(new_skills)
		
func _on_job_completed(job):
	if job != current_job:
		return
	current_job = null
