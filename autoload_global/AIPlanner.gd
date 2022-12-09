extends Node
#class_name AIPlanner

# Generic singleton action planner. For a given goal, picks the creature's best path to victory

func get_plan(tracker: GOAPStateTracker, goal: GOAPGoal) -> Array:
	var desired_outcome = goal.get_desired_outcome().duplicate()
	if desired_outcome.empty():
		return []

	return _find_best_plan(tracker, desired_outcome)

func _find_best_plan(tracker: GOAPStateTracker, desired_outcome: Dictionary):
	# the original code had desired_outcome duplicated again here, but I don't think it's necessary
	var root = {
		'action': tracker.current_goal,
		'state': desired_outcome,
		'children': []
	}

	# I don't understand why this has to be duplicated, when it's never mutated
	var tracker_state = tracker.get_state().duplicate()
	if _path_exists(tracker, root, tracker_state):
		var plans = _transform_tree_into_array(root, tracker_state)
		return _get_cheapest_plan(plans)
	
	return []
	
func _path_exists(tracker: GOAPStateTracker, step: Dictionary, tracker_state: Dictionary):
	var has_followup = false
	
	var desired_state = step.state.duplicate()
	for element in step.state:
		if desired_state[element] == tracker_state.get(element):
			desired_state.erase(element)
	
	# if desired_state is empty, all conditions have been satisfied by this plan
	if desired_state.empty():
		return true
		
	for action in tracker.actions:
		if !action.is_valid():
			continue
			
		var action_satisfies_requirement = false
		var action_results = action.get_results()
		var next_desired_state = desired_state.duplicate()
		
		for element in next_desired_state:
			# what if it doesn't exist in either one?
			if next_desired_state[element] == action_results.get(element):
				next_desired_state.erase(element)
				action_satisfies_requirement = true
		
		if action_satisfies_requirement:
			var requirements = action.get_requirements()
			for requirement in requirements:
				next_desired_state[requirement] = requirements[requirement]
			
			var next_step = {
				'action': action,
				'state': next_desired_state,
				'children': []
			}
			
			# is duplicating the actor_state necessary here? I don't think it's being mutated.
			if next_desired_state.empty() or _path_exists(tracker, next_step, tracker_state.duplicate()):
				step.children.push_back(next_step)
				has_followup = true
				
	return has_followup
				
func _transform_tree_into_array(p, blackboard):
	var plans = []

	if p.children.size() == 0:
		plans.push_back({ "actions": [p.action], "cost": p.action.get_cost(blackboard) })
		return plans

	for c in p.children:
		for child_plan in _transform_tree_into_array(c, blackboard):
			if p.action.has_method("get_cost"):
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.get_cost(blackboard)
			plans.push_back(child_plan)

	return plans
	
func _get_cheapest_plan(plans):
	var best_plan
	for p in plans:
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	return best_plan.actions
