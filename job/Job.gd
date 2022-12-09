extends Node
class_name Job

var worker: CreatureModel setget _set_worker

func _set_worker(val: CreatureModel):
	worker = val
# warning-ignore:return_value_discarded
	connect("job_completed", worker, '_on_job_completed')
	do_next_step()

var steps: Array = []

enum Step {
	GO_TO_LOCATION, 		# location: Vector2
	PICK_UP_ITEM, 		# item: ItemModel
	CLAIM_ITEM,			# item: ItemModel
}

func _init():
#	steps.append({ Step.GO_TO_LOCATION: loc })
	pass
	
func _ready():
	pass
	
func add_job_step(type: int, params: Array = []):
	steps.append({'type': type, 'params': params})
	pass

func do_next_step():
	if steps.size() == 0:
		emit_signal('job_completed', self)
		return
	var next_step = steps.pop_back()
	
	match next_step.type:
		Step.GO_TO_LOCATION:
			var loc = next_step.params[0] as Vector2
			worker.find_path_to_location(loc)
			worker.connect('reached_end_of_path', self, 'do_next_step', [], CONNECT_ONESHOT)
		Step.CLAIM_ITEM:
			var item = next_step.params[0] as ItemModel
			if item.claimed_by == null:
				item.was_claimed_by(worker)
			else:
				push_error('Item was already claimed')
	
	
	
	
	
#	if step_action == Step.GO_TO_LOCATION:
#		print('action: go to ', loc)
#
#		worker._find_path_to_location(loc)
#		# warning-ignore:return_value_discarded
#		worker.connect("reached_end_of_path", self, "_on_step_completed")
		
func _on_step_completed():
	steps.remove(0)
	if steps.size() == 0:
		emit_signal("job_completed", self)
	else:
		do_next_step()

signal job_completed(job)
