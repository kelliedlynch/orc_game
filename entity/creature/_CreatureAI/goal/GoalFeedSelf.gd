extends GOAPGoal
class_name GoalFeedSelf

var is_seeking_more: bool = false

# Things that must be true for this goal to be considered
func requirements(conditions: Dictionary = {}) -> Dictionary:
	var target_fullness = 50 if is_seeking_more else 30
	conditions = {
		'creature': {
			'fullness': [ LESS_THAN, target_fullness ],
		}
	}
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	# There is food that can be eaten
	conditions = {
		'items': {
			Group.Items.AVAILABLE_ITEMS: {
				HAS: [{ 'edible': true }]
			}
		}
	}
	return conditions

# The desired outcome of the goal
func desired_state(query: Dictionary = {}) -> Dictionary:
	query = {
		'creature': {
			'fullness': [ GREATER_OR_EQUAL, 50 ]
		}
	}
	return query

func get_priority() -> int:
	return Goal.PRIORITY_NEED

func get_class(): return 'GoalFeedSelf'
