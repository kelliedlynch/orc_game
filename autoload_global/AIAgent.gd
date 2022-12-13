extends Node
#class_name AIAgent

# Generic singleton creature agent. The agent takes a creature, looks at its state tracker,
# picks a goal, requests a plan from the planner, and executes the next step in the plan.

# Later there may be more Agents: i.e., FriendlyAgent, EnemyAgent, ResidentAgent

# TODO: FIX CYCLIC DEPENDENCIES WITH CREATURES

func run(actor: OGCreature):
	var tracker = actor.state_tracker
	var goal = _get_best_goal(actor)
	if goal == null: return
	if tracker.current_goal == null or goal != tracker.current_goal or tracker.current_plan.size() == 0:

#		var keys = _tracker._state.keys()
		for s in tracker.get_state():
#		for s in keys:
			tracker.current_goal = goal
			tracker.current_plan = AIPlanner.get_plan(tracker, tracker.current_goal)
			tracker.current_plan_step = 0
	else:
		_follow_plan(actor)
		
#
# Returns the highest priority goal available.
#
func _get_best_goal(actor: OGCreature):
	var goals = actor.state_tracker.goals.duplicate()
	var highest_priority
	var inactive_jobs = get_tree().get_nodes_in_group(Group.Jobs.INACTIVE_JOBS)
	var jobs_to_consider = []
	for job in inactive_jobs:
		if job.is_valid_for_creature(actor):
			job.assign_to_creature(actor)
			jobs_to_consider.append(job)
			
	goals.append_array(jobs_to_consider)
	for goal in goals:
		if goal.is_valid():
			var triggers = goal.trigger_conditions()
			var triggers_met = false if triggers.size() > 0 else true
			for condition in triggers:
				if triggers[condition] == actor.state_tracker.check_state_for(condition, triggers[condition]):
					triggers_met = true
				else:
					triggers_met = false
					break
			if triggers_met:
				if highest_priority == null or goal.get_priority() > highest_priority.get_priority():
					highest_priority = goal
					
	for job in jobs_to_consider:
		job.unassign()
		
	if highest_priority is Job:
		actor.state_tracker.add_goals([highest_priority])
		
	return highest_priority


#
# Executes plan. This function is called on every AI tick.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(actor: OGCreature):
	var plan = actor.state_tracker.current_plan
	var step = actor.state_tracker.current_plan_step
	if plan.size() == 0:
		return
	var is_step_complete = plan[step].perform(actor)
	if is_step_complete and step < plan.size() - 1:
		actor.state_tracker.current_plan_step += 1
