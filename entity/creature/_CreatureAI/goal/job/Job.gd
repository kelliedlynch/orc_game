extends GOAPGoal
class_name Job

# A Job is a subclass of Goal that can get added and removed from the StateTracker
# as it is initiated or completed. Each creature can only have one Job at a time.
var required_skills: Array 
var creator: Node

func get_priority() -> int:
	return Goal.PRIORITY_WORK

func get_class(): return 'Job'
