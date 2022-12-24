extends OGBuilt
class_name OGBuiltCampfire

func _init():
	size = 1
	weight = 1
	build_cost = 10
	entity_name = 'Campfire'
	instance_name = entity_name
	materials_required = [{ 'material': Item.Material.BONE }]
	add_to_group(Group.Builts.MEETING_PLACES)
	


func get_class(): return 'OGBuiltCampfire'
