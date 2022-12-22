extends GOAPQueryable
#class_name AIPlanner

# Generic singleton action planner. For a given goal, picks the creature's best path to victory

func get_plan(creature: OGCreature, goal: GOAPGoal) -> Array:
	var desired_outcome = goal.desired_state()
	if desired_outcome.empty():
		return []

	var root = {
		'desired_state': desired_outcome,
		'branching_paths': []
	}

	var state = simulate_world_state_for_creature(creature)
	var paths = _find_branching_paths(creature, root, state)
	if paths.empty():
		return []
	root.branching_paths = paths
		
	var cheapest_path = _pick_cheapest_branch(root, [])
	cheapest_path.invert()
	return cheapest_path
	
func _find_branching_paths(creature: OGCreature, step: Dictionary, state_: Dictionary) -> Array:
	var for_step = step.duplicate(true)
	var state = state_.duplicate(true)
	var return_array = []
	
	for action in creature.actions:
		# Find out if this action is relevant and doable
		if !action.is_valid(for_step.desired_state): 
			continue

		# See if performing the action will satisfy any conditions of the desired state
		var transformed_state = apply_transform_to_world_state(action.applied_transform(), state)
		var any_matches = any_conditions_satisfied(for_step.desired_state, transformed_state)
		# This action is irrelevant to the goal
		if !any_matches: 
			continue
		
		# See if we can currently perform this action
		var triggers = action.trigger_conditions()
		var trigger_conditions_met = eval_query(triggers, state)
		# If not, try to fulfill the trigger conditions
		var trigger_paths = []
		if !trigger_conditions_met:
			trigger_paths = _find_branching_paths(creature, triggers, transformed_state)
			# This action cannot be performed
			if trigger_paths.empty():
				continue
		# If we get this far, we can fulfill the trigger conditions for this action, and we should
		# add it to the return array
		var desired_state = remove_satisfied_conditions_from_query(for_step.desired_state, transformed_state)

		var prev_step = {
			'action': action,
			'desired_state': desired_state,
			'branching_paths': trigger_paths
		}
		return_array.append(prev_step)
		
		# If desired state is empty here, completing this action will fulfill the goal
		# If not, we need to find other actions to satisfy the desired state
		var modified_for_step = for_step.duplicate(true)
		modified_for_step.desired_state = desired_state
		if !desired_state.empty():
			var addl_paths = _find_branching_paths(creature, prev_step, state)
			trigger_paths.append_array(addl_paths)

	return return_array
			


func _any_conditions_satisfied_by_action(action: GOAPAction, desired_state: Dictionary, state: Dictionary) -> bool:
	var new_state = state.duplicate(true)
	var transformed_state = action.applied_transform()
	var outcome = apply_transform_to_world_state(new_state, transformed_state)
	var any_matches = any_conditions_satisfied(desired_state, outcome)
	return any_matches
	
func _pick_cheapest_branch(path: Dictionary, prev_steps: Array) -> Array:
	if path.branching_paths.empty():
		prev_steps.append({ 'action': path.action, 'total_cost': path.action.get_cost() })
		prints('action', path.action, 'cost', path.action.get_cost())
		return prev_steps
	var cheapest_path
	for branch in path.branching_paths:
		var cheapest = _pick_cheapest_branch(branch, prev_steps)
		if !cheapest_path or cheapest.back()['total_cost'] < cheapest_path.back()['total_cost']:
			cheapest_path = cheapest
	var next = cheapest_path.back()
	if path.has('action'):
		var cost = next.total_cost + path.action.get_cost() if path.action else next.total_cost
		prev_steps.append({ 'action': path.action, 'total_cost': cost })
	return prev_steps
