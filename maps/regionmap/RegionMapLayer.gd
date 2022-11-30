extends TileMap
class_name RegionMapLayer


func _init():
	set_cell_size(Vector2(16.0, 16.0))
	tile_set = preload("res://terrain/terrain tiles.tres")
