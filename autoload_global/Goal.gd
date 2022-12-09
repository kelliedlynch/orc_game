extends Node

var HoldBone = GoalHoldBone.new()
var EntertainSelf = GoalEntertainSelf.new()

func _ready():
	add_child(HoldBone)
	add_child(EntertainSelf)
