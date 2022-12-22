extends Sprite
class_name EntitySprite

var _is_ghost: bool = false setget set_is_ghost

func set_is_ghost(val):
	_is_ghost = val
	emit_signal('ghost_status_changed')
signal ghost_status_changed()

func _init() -> void:
	connect('ghost_status_changed', self, '_on_ghost_status_changed')

#func _ready():
#	z_index = Global.RenderLayer.SPRITE_LAYER

func _on_ghost_status_changed():
	var alpha = 1.0
	if _is_ghost: alpha = 0.4
	modulate.a = alpha
		
func get_class(): return 'EntitySprite'
