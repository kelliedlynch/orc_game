extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func tab_index_changed(isFirst: bool, isLast: bool):
	disabled = isFirst
