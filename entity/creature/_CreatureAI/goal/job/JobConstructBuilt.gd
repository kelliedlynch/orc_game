extends Job
class_name JobConstructBuilt
#
var built: OGBuilt
#

# Things that must be true for this goal to be considered
func requirements(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			'skills': {
				HAS: [ Creature.Skill.BUILDING ]
			}
		},
		'items': {
			Group.Items.AVAILABLE_ITEMS: {
				HAS: built.materials_required
			}
		}
	}
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		
	}
	return conditions

# The desired outcome of the goal
func desired_state(query: Dictionary = {}) -> Dictionary:
	query = {
		'job':{
			'built': {
				'is_complete': true
			}
		}
	}
#	query.append_array([])
	return query



func get_class(): return 'JobConstructBuilt'
