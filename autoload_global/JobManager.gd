extends Node

func assign_job_to_creature(job: Job, creature: OGCreature):
	job.creature = creature
	job.remove_from_group(Group.Jobs.INACTIVE_JOBS)
	creature.goals.append(job)
	
func unassign_job(job: Job):
	job.creature.remove_child(job)
	job.creature.goals.remove(job.creature.goals.find(job))
	job.creature = null
	job.add_to_group(Group.Jobs.INACTIVE_JOBS)
	
func generate_job_for_built(built: OGBuilt):
	var job = JobConstructBuilt.new()
	job.built = built
	job.creator = built
	job.add_to_group(Group.Jobs.ALL_JOBS)
	job.add_to_group(Group.Jobs.INACTIVE_JOBS)
	job.creator.add_child(job)

func remove_job_for_built(built: OGBuilt):
	# TODO: THIS IS HACKY GARBAGE, PLEASE USE SIGNALS INSTEAD
	for job in get_tree().get_nodes_in_group(Group.Jobs.ALL_JOBS):
		if job.built == built:
			for creature in get_tree().get_nodes_in_group(Group.Creatures.ALL_CREATURES):
				if job in creature.goals:
					creature.goals.remove(creature.goals.find(job))
				if creature.current_goal == job:
					creature.current_goal = null
			job.creator.remove_child(job)
			job.queue_free()
			break
