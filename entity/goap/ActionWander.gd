extends GOAPAction
class_name ActionWander

func get_requirements():
	return { 
		'is_entertained': false
	}

func get_results():
	return {
		'is_entertained': true
	}

func perform(actor, _delta):
	var valid = CreatureManager.map.locations_adjacent_to(actor.location)
	var i = randi() % valid.size()
	actor.set_location(valid[i])
	return false
