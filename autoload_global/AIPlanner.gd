extends GOAPQueryable
#class_name AIPlanner

# Generic singleton action planner. For a given goal, picks the creature's best path to victory

func get_plan(creature: OGCreature, goal: GOAPGoal) -> Array:
	var desired_outcome = goal.end_state().duplicate()
	if desired_outcome.empty():
		return []

	return _find_best_plan(creature, desired_outcome)

func _find_best_plan(creature: OGCreature, goal: GOAPGoal):
	# the original code had desired_outcome duplicated again here, but I don't think it's necessary
#	var root = {
#		'action': creature.state_tracker.current_goal,
#		'state': desired_outcome,
#		'children': []
#	}
	var root = {
		'desired_state': goal.desired_state(),
		'trigger_conditions': {},
		'potential_actions': []
	}

	# I don't understand why this has to be duplicated, when it's never mutated
	var tracker_state = creature.state_tracker.get_state().duplicate()
	if _path_exists(creature, root, tracker_state):
		var plans = _transform_tree_into_array(root, tracker_state)
		return _get_cheapest_plan(plans)
	
	return []
	
func _path_exists(creature: OGCreature, step: Dictionary, simulated_state: Dictionary = {}):
	var keep_searching = false
	
	var next_step = step.duplicate
	
	for action in creature.state_tracker.actions:
		# 'requirements' are things that can't be changed during an action path. If they aren't valid
		# in the current state of the world, the action won't be considered. (Is this a thing I even want?)
		var is_valid = eval_query(action.requirements(), simulated_state)
		if !is_valid: continue
		
		var this_step = {
			'desired_state': action.trigger_conditions,
#			'trigger_conditions': action.trigger_conditions,
			# potential previous actions to make desired_state true
			'potential_actions': []
		}
		
		var transformed_state = apply_transform_to_world_state(action.applied_transform, simulated_state)
		var any_matches = any_conditions_satisfied(next_step.desired_state, transformed_state)
		if !any_matches: continue

#		next_step.desired_state = Creature.IdleState.PLAYING
#		next_step.trigger_conditions = Creature.IdleState.IDLE
		var trigger_conditions_met = eval_query(action.trigger_conditions(), simulated_state)
		if !trigger_conditions_met: 
#			this_step.desired_state = apply_transform_to_world_state(action.applied_transform, next_step.desired_state)
			var paths = _path_exists(creature, this_step, simulated_state)
			if paths.size() > 0:
				# ???
				next_step.potential_actions.append(this_step)
		var all_conditions_satisfied = eval_query(next_step.desired_state, transformed_state)
		

func _any_conditions_satisfied_by_action(action: GOAPAction, desired_state: Dictionary, state: Dictionary) -> bool:
	var new_state = state.duplicate(true)
	var transformed_state = action.applied_transform()
	var outcome = apply_transform_to_world_state(new_state, transformed_state)
	var any_matches = any_conditions_satisfied(desired_state, outcome)
	return any_matches
	
#	var desired_state = step.goal.duplicate()
#
#
#	for action in creature.state_tracker.actions:
#		if !evaluate_query(action.requirements(), creature):
#			continue
#
#		var q = evaluate_query(desired_state, creature, action.end_result())
#
#		var action_satisfies = false
#		var action_results = action.get_results()
#		var next_desired_state = desired_state.duplicate()
#
#		for element in next_desired_state:
#			# what if it doesn't exist in either one?
#			if next_desired_state[element] == action_results.get(element):
#				next_desired_state.erase(element)
##				action_satisfies_requirement = true
#
##		if action_satisfies_requirement:
##			var requirements = action.get_requirements()
##			for requirement in requirements:
##				next_desired_state[requirement] = requirements[requirement]
#
#			var next_step = {
#				'action': action,
#				'state': next_desired_state,
#				'children': []
#			}
#
#			# is duplicating the actor_state necessary here? I don't think it's being mutated.
##			if next_desired_state.empty() or _path_exists(creature.state_tracker, next_step, tracker_state.duplicate()):
##				step.children.push_back(next_step)
##				has_followup = true
				
				
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
	
func _get_cheapest_plan(plans: Array):
	var best_plan
	for p in plans:
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	return best_plan.actions
