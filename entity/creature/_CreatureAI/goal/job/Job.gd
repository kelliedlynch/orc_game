extends GOAPGoal
class_name Job

# A Job is a subclass of Goal that can get added and removed from the StateTracker
# as it is initiated or completed. Each creature can only have one Job at a time.
var required_skill: int 

func _ready():
	connect('job_assigned', JobDispatch, '_on_job_assigned')
	connect('job_unassigned', JobDispatch, '_on_job_unassigned')

signal job_assigned(Job)
signal job_unassigned(Job)

func is_valid_for_creature(creature: OGCreature) -> bool:
	if creature.skills.has(required_skill):
		return true
	return false

func assign_to_creature(creature: OGCreature):
	.assign_to_creature(creature)
	emit_signal('job_assigned', self)

func unassign():
	actor.state_tracker.stop_tracking_state('job_completed')
	.unassign()
	emit_signal('job_unassigned', self)

func get_priority() -> int:
	return Goal.PRIORITY_WORK

func get_class(): return 'Job'
