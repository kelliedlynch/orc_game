extends GOAPQueryable
#class_name AIAgent

# The agent takes a creature, looks at its state tracker,
# picks a goal, requests a plan from the planner, and executes the next step in the plan.

func run(creature: OGCreature):
	var state = simulate_world_state_for_creature(creature)
	if creature.current_goal:
		# Just check that the current goal is still relevant, don't do the whole planning process
		var valid = _check_goal_validity(creature.current_goal, state)
		if valid: 
			_follow_plan(creature)
			return
			
	# Current goal does not exist or is not relevant; pick a new goal
	var best_goal = _get_best_goal(creature, state)
	var plan = AIPlanner.get_plan(creature, best_goal)
	creature.current_plan = plan
	_follow_plan(creature)
	

func _check_goal_validity(goal: GOAPGoal, state: Dictionary) -> bool:
	var valid = eval_query(goal.requirements(), state)
	if !valid:
		 return false
	var triggered = eval_query(goal.trigger_conditions(), state)
	if !triggered: 
		return false

	# This might need to do more checks, such as checking that the current path is still followable
	return true

#
# Returns the highest priority goal available.
#
func _get_best_goal(creature: OGCreature, state: Dictionary) -> GOAPGoal:
	var goals = creature.goals
	var highest_priority
	var inactive_jobs = get_tree().get_nodes_in_group(Group.Jobs.INACTIVE_JOBS)
	var jobs_to_consider = []
	for job in inactive_jobs:
		if job.is_valid_for_creature(creature):

			jobs_to_consider.append(job)
			
		goals.append_array(jobs_to_consider)
		for goal in goals:
			var valid = _check_goal_validity(goal, state)
			if !valid: continue
		

			if highest_priority == null or goal.get_priority() > highest_priority.get_priority():
				highest_priority = goal
		
	if creature.current_goal and creature.current_goal != highest_priority and creature.current_goal is Job:
		creature.current_goal.unassign()
		
	if highest_priority is Job:
		highest_priority.assign_to_creature(creature)
		
	return highest_priority

func _follow_plan(creature: OGCreature):
	var plan = creature.current_plan
	var step = creature.current_plan_step
	if plan.size() == 0:
		return
	var is_step_complete = plan[step].perform(creature)
	if is_step_complete and step < plan.size() - 1:
		creature.current_plan_step += 1
