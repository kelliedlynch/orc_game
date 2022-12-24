extends GOAPQueryable
#class_name AIAgent

# The agent takes a creature, looks at its state tracker,
# picks a goal, requests a plan from the planner, and executes the next step in the plan.

func run(creature: OGCreature):
	var state = simulate_world_state_for_creature(creature)
	if creature.current_goal:
		# Just check that the current goal is still relevant, don't do the whole planning process
		var valid = _check_goal_validity(creature.current_goal, state)
		# Also check that the creature has a current plan for the goal
		valid = !creature.current_plan.empty()
		if valid: 
			_follow_plan(creature)
			return
			
	# Current goal does not exist or is not relevant; pick a new goal
	var best_goal = _get_best_goal(creature, state)
	if creature.current_goal and creature.current_goal != best_goal and creature.current_goal is Job:
		creature.current_goal.unassign()
	if best_goal is Job:
		JobManager.assign_job_to_creature(best_goal, creature)

	creature.current_goal = best_goal
	var plan = AIPlanner.get_plan(creature, best_goal)
	creature.current_plan = plan
	creature.current_plan_step = 0
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


func _get_best_goal(creature: OGCreature, state: Dictionary) -> GOAPGoal:
	var goals = creature.goals.duplicate()
	var highest_priority
	var inactive_jobs = get_tree().get_nodes_in_group(Group.Jobs.INACTIVE_JOBS)
	var highest_priority_job
	for job in inactive_jobs:
		var valid = _check_goal_validity(job, state)
		if valid:
			if !highest_priority_job or job.get_priority() > highest_priority_job.get_priority():
				highest_priority_job = job
	if highest_priority_job: 
		goals.append(highest_priority_job)
		
	for goal in goals:
		if !(goal is Job) and !_check_goal_validity(goal, state):
			continue
	
		if highest_priority == null or goal.get_priority() > highest_priority.get_priority():
			highest_priority = goal
		
	return highest_priority

func _follow_plan(creature: OGCreature):
	var plan = creature.current_plan
#	var step = creature.current_plan_step
	if !plan.empty():
		var is_step_complete = plan.back().action.perform()
		if is_step_complete:
			plan.pop_back()

