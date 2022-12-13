extends Node
class_name GOAPAction

func is_valid() -> bool:
	return true

func get_requirements() -> Dictionary:
	return {}
	
func get_results() -> Dictionary:
	return {}
	
func get_cost(_blackboard) -> int:
	return 0
