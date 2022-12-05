extends Node
class_name Job

var worker: CreatureModel = null

var steps = [
	{ Step.GO_TO_LOCATION: { 'x': 0, 'y': 0 } }
]

enum Step {
	GO_TO_LOCATION,
}

func _init(x, y):
	steps[0][Step.GO_TO_LOCATION].x = x
	steps[0][Step.GO_TO_LOCATION].y = y

func do_next_step():
	if steps.size() == 0:
		emit_signal('job_completed', self)
		return
	var step_action = steps[0].keys()[0]
	var step = steps[0][step_action]
	if step_action == Step.GO_TO_LOCATION:
		worker.path_to_tile(step.x, step.y)
		if worker.connect("move_completed", self, "_on_step_completed"):
			push_error('move_completed connect failed in Job')
	
func _on_step_completed():
	steps.remove(0)
	do_next_step()

signal job_completed(job)
