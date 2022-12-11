extends Node2D

onready var _highlight_rect: ColorRect = $HighlightRect
onready var _ani_player: AnimationPlayer = $HighlightRect/AnimationPlayer


func set_position(pos) -> void:
	if !pos:
		_highlight_rect.visible = false
		_ani_player.stop()
		return
	_highlight_rect.set_position(pos)
	_highlight_rect.visible = true
	_ani_player.play('cursor_blink')
