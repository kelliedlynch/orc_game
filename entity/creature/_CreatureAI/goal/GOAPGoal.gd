extends Node
class_name GOAPGoal

var actor: OGCreature

# TODO: FIX CYCLIC DEPENDENCIES WITH CREATURES

func assign_to_creature(creature: OGCreature):
	actor = creature

func unassign():
	actor = null

func is_valid() -> bool:
	return true

func get_priority() -> int:
	return Goal.PRIORITY_IDLE
	
func trigger_conditions() -> Dictionary:
	return {}
	
func get_desired_outcome() -> Dictionary:
	return {}

func get_class(): return 'GOAPGoal'

