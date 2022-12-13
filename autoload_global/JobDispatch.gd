extends Node

var interval: float = 2.0
var elapsed: float = 0


func _add_job_to_queue(job: Job):
	job.add_to_group(Group.Jobs.INACTIVE_JOBS)


func generate_job_for_built(built: OGBuilt):
	var job = JobConstructBuilt.new(built)
	add_child(job)
	_add_job_to_queue(job)

func _on_job_assigned(job: Job):
	job.remove_from_group(Group.Jobs.INACTIVE_JOBS)
	job.add_to_group(Group.Jobs.ACTIVE_JOBS)
	
func _on_job_unassigned(job: Job):
	job.remove_from_group(Group.Jobs.ACTIVE_JOBS)
	job.add_to_group(Group.Jobs.INACTIVE_JOBS)

func _on_job_completed(job):
	job.remove_from_group(Group.Jobs.ACTIVE_JOBS)
	job.queue_free()
	
#func _process(delta):
#	elapsed += delta
#	if elapsed > interval:
#		for job in get_tree().get_nodes_in_group(Group.Jobs.INACTIVE_JOBS):
#			emit_signal('worker_requested', job)
#		elapsed = 0
