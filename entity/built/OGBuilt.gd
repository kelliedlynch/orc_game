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
	sprite.set_is_ghost(!is_complete)

var is_suspended: bool = false
const QTY = 'QUANTITY'
var materials_required: Array = []
var _required_materials_remaining: Array = []


func use_item_in_construction(item: OGItem):
	var all_props_match = true
	var index = -1
	for mat in _required_materials_remaining:
		index +=1
		var material = mat.duplicate()
		var qty_needed = 1
		if QTY in material:
			qty_needed = material[QTY]
			material.erase(QTY)
		if item.has_all(material.keys()):
			qty_needed -= 1
			ItemManager.item_used_in_built(item)
			if qty_needed <= 0:
				_required_materials_remaining[index] = null
			else:
				_required_materials_remaining[index][QTY] = qty_needed
			break
	while null in _required_materials_remaining:
		_required_materials_remaining.remove(_required_materials_remaining.find(null))


func _ready():
	_required_materials_remaining = materials_required
	if !is_complete:
		$EntitySprite.set_is_ghost(true)
		JobManager.generate_job_for_built(self)

func is_materials_cost_paid() -> bool:
	return _required_materials_remaining.empty()
