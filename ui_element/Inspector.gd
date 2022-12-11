extends CanvasLayer

onready var _selection_indicator: Node2D = $SelectionIndicator
onready var _mouse_position_indicator: Node2D = $MousePositionIndicator
onready var _inspector_window: TabContainer = $InspectorWindow

func _ready():
	Global.connect('player_target_changed', self, '_on_player_target_changed')

func _on_player_target_changed(target: Object, prev: Object = null):
	var loc = target.location if target else null
	_selection_indicator.set_location(loc)
#	_inspector_window.set_target_location(loc)
	if target && target is OGEntity:
		target.connect("location_changed", self, "_cursor_target_moved")
	if prev is OGEntity:
		prev.disconnect("location_changed", self, "_cursor_target_moved")

func _process(_delta):
	_selection_indicator.visible = !(_inspector_window.get_target_location() == null)

func _cursor_target_moved(_target, loc: Vector2, _oldval):
	_selection_indicator.set_location(loc)

func _unhandled_input(event):
	match event.get_class():
		'InputEventMouseMotion':
			var pos = SpriteManager.snap_position_to_grid(event.position)
			_mouse_position_indicator.set_position(pos)
