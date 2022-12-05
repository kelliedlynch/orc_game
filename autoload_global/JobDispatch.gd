extends Node

#const Job = load("res://jobs/Job.gd")

var active_jobs = []
var inactive_jobs = []

#func _ready():
#	self.connect('job_accepted', self, '_on_job_accepted')

func new_job(x: int = 0, y: int = 0):
	prints('creating new job', x, y)
	var job = Job.new(x, y)
	inactive_jobs.append(job)
	job.connect("job_completed", self, "_on_job_completed")
	emit_signal('worker_requested', job)

signal worker_requested(job)

func _on_job_accepted(job: Job, worker: CreatureModel):
	if job.worker == null:
		worker.current_job = job
		job.worker = worker
		inactive_jobs.remove(inactive_jobs.find(job))
		active_jobs.append(job)
		job.do_next_step()

func _on_job_abandoned(job: Job):
	active_jobs.remove(active_jobs.find(job))
	inactive_jobs.append(job)
	job.worker.current_job = null
	job.worker = null
	emit_signal('worker_requested', job)

func _on_job_completed(job):
	active_jobs.remove(active_jobs.find(job))
	job.queue_free()
