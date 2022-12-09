extends Node
class_name GOAPPlanner

# Each creature will have its own Planner (?). The planner knows all actions a creature can take.
# It creates plans that lead to a given goal.

# I may want to have a few static Planners instead of one per creature. 
# FriendlyPlanner, EnemyPlanner, AnimalPlanner

# Since each creature has its own Planner, creatures are currently responsible for adding
# actions to their Planner

var _actions: Array = []

func _ready():
	pass

func add_actions(actions: Array):
	# TODO: check this array for duplicate actions
	_actions.append_array(actions)

func get_plan(goal: GOAPGoal, actor_state: Dictionary) -> Array:
	var desired_outcome = goal.get_desired_outcome().duplicate()
	if desired_outcome.empty():
		return []

	return _find_best_plan(goal, desired_outcome, actor_state)

func _find_best_plan(goal: GOAPGoal, desired_outcome: Dictionary, actor_state: Dictionary):
	# the original code had desired_outcome duplicated again here, but I don't think it's necessary
	var root = {
		'action': goal,
		'state': desired_outcome,
		'children': []
	}

	# I don't understand why this has to be duplicated, when it's never mutated
	if _build_plans(root, actor_state.duplicate()):
		var plans = _transform_tree_into_array(root, actor_state)
		return _get_cheapest_plan(plans)
	
	return []
	
func _build_plans(step: Dictionary, actor_state: Dictionary):
	var has_followup = false
	
	var desired_state = step.state.duplicate()
	for element in step.state:
		if desired_state[element] == actor_state.get(element):
			desired_state.erase(element)
	
	# if desired_state is empty, all conditions have been satisfied by this plan
	if desired_state.empty():
		return true
		
	for action in _actions:
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
			if next_desired_state.empty() or _build_plans(next_step, actor_state.duplicate()):
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
