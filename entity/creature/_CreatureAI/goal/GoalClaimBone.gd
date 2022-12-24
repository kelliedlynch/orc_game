extends GOAPGoal
class_name GoalClaimBone

# Things that must be true for this goal to be considered
func requirements(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		OR: {
			'items': {
				Group.Items.AVAILABLE_ITEMS: {
					HAS: [
						{ 'material': Item.Material.BONE }
					]
				}
			},
			'creature': {
				'owned': {
					HAS: [
						{ 'material': Item.Material.BONE }
					]
				}
			}
		}
	}
	return conditions

# The conditions that activate the goal
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:
	conditions = {
		'creature': {
			NOT: {
				OR: {
					'owned': {
						HAS: [
							{ 'material': Item.Material.BONE }
						]
					},
					'inventory': {
						HAS: [
							{ 'material': Item.Material.BONE }
						]
					}
					
				}
			}
		}
	}
	return conditions

# The desired outcome of the goal
func desired_state(query: Dictionary = {}) -> Dictionary:
	query = {
		'creature': {
			'owned': {
				HAS: [
					{ 'material': Item.Material.BONE }
				]
			},
			'inventory': {
				HAS: [
					{ 'material': Item.Material.BONE }
				]
			}
		}
	}
	return query
	
func get_priority():
	return Goal.PRIORITY_WANT

func get_class(): return 'GoalClaimBone'
