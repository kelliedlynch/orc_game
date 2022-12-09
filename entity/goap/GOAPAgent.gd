extends Node
class_name GOAPAgent

# Each creature will have its own Agent. The Agent tracks the creature's list of goals,
# current plan, and step in the plan. The Agent also requests new plans from the AI when
# the creature has no plan.

onready var actor: OGCreature = get_parent()
onready var state_tracker: GOAPStateTracker = $GOAPStateTracker
onready var planner: GOAPPlanner = $GOAPPlanner


var _goals: Array
var _current_goal
var _current_plan: Array = []
var _current_plan_step = 0

func _ready():
	pass

func add_goals(goals: Array):
	for goal in goals:
		goal.actor = actor
		goal.state_tracker = state_tracker
		_goals.append(goal)

func run_GOAP():
#	if !planner: return
	var goal = _get_best_goal()
	if goal == null: return
	if _current_goal == null or goal != _current_goal or _current_plan.size() == 0:

#		var keys = _actor.state_tracker._state.keys()
		for s in state_tracker._state:
#		for s in keys:
			_current_goal = goal
			_current_plan = planner.get_plan(_current_goal, state_tracker._state.duplicate())
			_current_plan_step = 0
	else:
		_follow_plan(_current_plan)
		
#
# Returns the highest priority goal available.
#
func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid():
			var triggers = goal.trigger_conditions()
			var triggers_met = false if triggers.size() > 0 else true
			for condition in triggers:
				if triggers[condition] == state_tracker.check_state_for(condition, triggers[condition]):
					triggers_met = true
				else:
					triggers_met = false
					break
			if triggers_met:
				if highest_priority == null or goal.get_priority() > highest_priority.get_priority():
					highest_priority = goal

	return highest_priority


#
# Executes plan. This function is called on every game loop.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(plan):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(get_parent())
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
