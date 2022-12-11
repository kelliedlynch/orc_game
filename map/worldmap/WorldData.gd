extends Node

var world_map_tiles: Array = []

var _current_map: OrcGameMap setget set_current_map, get_current_map

func set_current_map(map: OrcGameMap) -> void:
	_current_map = map
	emit_signal("current_map_changed", _current_map)
signal current_map_changed()
func get_current_map() -> OrcGameMap:
	return _current_map
