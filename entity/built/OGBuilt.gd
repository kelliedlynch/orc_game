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
	if is_complete: emit_signal('built_completed')
signal built_completed()

var is_suspended: bool = false
const QTY = 'QUANTITY'
var materials_required: Array = []
var _materials_used: Array = []
var _required_materials_remaining: Array = []


func _on_built_completed():
	sprite.set_is_ghost(false)
	for mat in _materials_used:
		ItemManager.remove_from_world(mat)
	JobManager.remove_job_for_built(self)

func use_item_in_construction(item: OGItem):
	var index = -1
	for mat in _required_materials_remaining:
		index +=1
		var material = mat.duplicate()
		var qty_needed = 1
		if QTY in material:
			qty_needed = material[QTY]
			material.erase(QTY)
			
		var is_match = true
		for key in material.keys():
			if item.get(key) == null:
				is_match = false
				break
			if item.get(key) != material[key]:
				is_match = false
				break
		if !is_match:
			continue
		qty_needed -= 1
		_materials_used.append(item)
		if qty_needed <= 0:
			_required_materials_remaining[index] = null
		else:
			_required_materials_remaining[index][QTY] = qty_needed
		break
	while null in _required_materials_remaining:
		_required_materials_remaining.remove(_required_materials_remaining.find(null))


func _ready():
	connect('built_completed', self, '_on_built_completed')
	_required_materials_remaining = materials_required
	if !is_complete:
		$EntitySprite.set_is_ghost(true)
		JobManager.generate_job_for_built(self)

func is_materials_cost_paid() -> bool:
	return _required_materials_remaining.empty()
	
func _exit_tree() -> void:
	for job in get_tree().get_nodes_in_group(Group.Jobs.INACTIVE_JOBS):
		if job.built == self:
			JobManager.remove_child(job)
			job.queue_free()
