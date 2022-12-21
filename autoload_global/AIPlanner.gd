extends GOAPQueryable
#class_name AIPlanner

# Generic singleton action planner. For a given goal, picks the creature's best path to victory

func get_plan(creature: OGCreature, goal: GOAPGoal) -> Array:
	var desired_outcome = goal.desired_state().duplicate()
	if desired_outcome.empty():
		return []

	var root = {
		'desired_state': desired_outcome,
		'trigger_conditions': {},
		'branching_paths': []
	}

	var state = simulate_world_state_for_creature(creature)
	var paths = _path_exists(creature, root, state)
	if paths.empty():
		return []
		
	var cheapest_path = _pick_cheapest_branch(paths, [])
	cheapest_path.invert()
	return cheapest_path
	
func _path_exists(creature: OGCreature, step: Dictionary, state: Dictionary) -> Dictionary:
	
	var next_step = step.duplicate()
	
	for action in creature.actions:
		if !action.is_valid(next_step.desired_state): 
			continue
		
		var this_step = {
			'action': action,
			'desired_state': next_step.desired_state,
			'trigger_conditions': action.trigger_conditions(),
			'branching_paths': []
		}

		var transformed_state = apply_transform_to_world_state(action.applied_transform(), state)
		var any_matches = any_conditions_satisfied(next_step.desired_state, transformed_state)
		if !any_matches: 
			continue

		var trigger_conditions_met = eval_query(action.trigger_conditions(), state)
		pass
		if !trigger_conditions_met: 
			var paths = _path_exists(creature, this_step, state)
			
			if paths.empty():
				# This is a dead-end--no routes to the current world state exist
				continue
			else:
				this_step.desired_state = remove_satisfied_conditions_from_query(next_step.desired_state, transformed_state)
				next_step.trigger_conditions = remove_satisfied_conditions_from_query(next_step.trigger_conditions, transformed_state)
		else:
			this_step.desired_state = remove_satisfied_conditions_from_query(next_step.desired_state, transformed_state)
			this_step.trigger_conditions = {}
		next_step.branching_paths.append(this_step)
	
	if next_step.trigger_conditions.empty():
		# all goals for this branch have been satisfied.
		return next_step
	return {}

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
		prev_steps.append({ 'action': path.action, 'total_cost': next.total_cost + path.action.get_cost()})
	return prev_steps
