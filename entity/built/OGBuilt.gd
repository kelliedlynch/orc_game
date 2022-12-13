extends OGEntity
class_name OGBuilt

var build_cost: float
var build_cost_paid: float = 0 setget _set_build_cost_paid
func _set_build_cost_paid(val):
	build_cost_paid = val
	if build_cost_paid >= build_cost:
		self.is_complete = true

var is_complete: bool = false setget _set_is_complete
func _set_is_complete(val):
	is_complete = val
	if is_complete:
		$EntitySprite.modulate.a = 1.0
	emit_signal('completed_changed', self)
signal completed_changed()

var is_paused: bool = false
var required_materials: Dictionary = {}
var _materials_used: Dictionary = {}


func use_item_in_construction(item: OGItem):
	for material_name in required_materials:
		if material_name == item.get_class():
			if _materials_used[material_name] < required_materials[material_name]:
				_materials_used[material_name] += 1
				item.add_to_group(Group.Item.USED_IN_BUILT)


func _ready():
	for material_name in required_materials:
		_materials_used[material_name] = 0
	
	if !is_complete:
		$EntitySprite.modulate.a = 0.4
		construct()

func construct():
	JobDispatch.generate_job_for_built(self)

func is_materials_cost_paid() -> bool:
	for material_name in required_materials:
		if required_materials[material_name] > _materials_used[material_name]:
			return false
	return true
