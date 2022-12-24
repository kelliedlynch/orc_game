extends GOAPAction
class_name ActionEatFood

var food: OGItem

# Targeted actions need to find a target in their is_valid method
func is_valid(query: Dictionary) -> bool:
	# Action is relevant if creature wants to increase fullness
	if !(query.has('creature') and query['creature'].has('fullness')):
		return false
	var operator
	var goal_value = query['creature']['fullness']
	if goal_value is Array:
		var op = goal_value.front()
		goal_value = goal_value.back()
		if op == LESS_OR_EQUAL or op == LESS_THAN:
			return false
		else: operator = op
	else:
		operator = GREATER_OR_EQUAL
	
	var is_relevant =  _eval_operator_query(operator, goal_value, creature.fullness)
	if !is_relevant: return false
			
	# May also be relevant for other things later, such as if there are foods that provide buffs
	
	# If a food is already selected for this action, and is still valid, return true immediately
	if food and food.nutrition_value > 1 and ItemManager.item_is_available_to(food, creature): 
		return true
	elif food:
		food = null
	
	# Otherwise, find the best food available and select it for this action
	var props = {
		'edible': true,
		'nutrition_value': [GREATER_THAN, 1]
	}
	
	# If the creature is already carrying suitable food, eat that
	for item in creature.inventory:
		if item.edible:
			var sim = simulate_object(item)
			var valid = _eval_has_condition(props, sim)
			if valid:
				food = item
				return true
				
	# If creature is not carrying suitable food, find it in the world
	var foods = ItemManager.find_all_available_items_with_properties(props, ItemManager.PREFER_CLOSER, creature)
	var best_choice
	var best_backup
	for this_food in foods:
		if this_food.nutrition_value >= 30:
			best_choice = this_food
			break
		elif !best_backup or this_food.nutrition_value > best_backup:
			best_backup = this_food
	if best_choice:
		food = best_choice
		return true
	elif best_backup:
		food = best_backup
		return true
	return false

# The requirements for this action that could be affected by other actions
func trigger_conditions(conditions: Dictionary = {}) -> Dictionary:

	return conditions

# The outcome of the Action
# This action lies about results--promises 100 fullness, but only delivers what the food delivers.
# This means the creature will continue taking the action until desired fullness is reached
func applied_transform(transform: Dictionary = {}) -> Dictionary:
	transform = {
		'creature': {
			'fullness': { ADD: 100 },
		}
	}
	return transform

func get_cost() -> int:
	return 1
	
func reset():
	food = null
	
func perform():
	if creature.inventory.has(food):
		# TODO: This should probably take some time, instead of happening instantly
		creature.fullness += food.nutrition_value
		ItemManager.remove_from_world(food)
		food = null
		return true
	if creature.location == food.location:
		ItemManager.creature_pick_up_item(creature, food)
		return false
	creature.move_toward_location(food.location)
	return false

func get_class(): return 'ActionEatFood'
