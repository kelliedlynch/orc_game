extends Node2D

onready var _outline_rect: ReferenceRect = $OutlineRect
onready var _ani_player: AnimationPlayer = $OutlineRect/AnimationPlayer


func set_location(loc) -> void:
	if !loc:
		_outline_rect.visible = false
		_ani_player.stop()
		return
	var pos = SpriteManager.location_to_position(loc)
	_outline_rect.set_position(pos)
	_outline_rect.visible = true
	_ani_player.play('cursor_blink')
