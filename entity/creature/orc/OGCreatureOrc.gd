extends CreatureModel
class_name OGCreatureOrc

func _init():
	type = CreatureType.Type.TYPE_HUMANOID
	subtype = CreatureSubtype.Subtype.SUBTYPE_ORC

	first_name_complete = ['Grug', 'Thog', 'Grest', 'Ogor', 'Ogon', 'Krag', 'Patrick']
	first_name_syllable1 = ['Gr\'', 'Ku', 'Tak', 'Gor', 'Da', 'K\'', 'Bak']
	first_name_syllable2 = ['thor', 'brag', 'duk', 'thak', 'tar', 'gar', 'dar', 'deg']
	first_name_word1 = ['Snaggle', 'Rock', 'Green', 'Red', 'Yellow', 'Black', 'Crack', 'Gore', 'Dark', 'Sharp']
	first_name_word2 = ['tooth', 'tusk', 'fang', 'heart', 'gut', 'wart', 'fist', 'grin', 'grip']
	first_name = generate_first_name()
	
	behavior_priority[Priority.LOW].append('pick_up_bone')

func _ready():
	body.sprite.texture = load('res://entity/creature/orc/og_creature_orc.tres')
	
func _choose_next_behavior():
	pass
	
func _find_path_to_location(loc: Vector2):
	var path = Global.pathfinder.get_path(location, loc)
	path.invert()
	self.current_path = path

func __job__pick_up_bone() -> bool:
	# Orcs like bones. If it doesn't have one in inventory, and one is available
	# somewhere, pick it up.
	if inventory.has(OGItemBone):
		print('has bone')
		return false
	else:
		var unclaimed = get_tree().get_nodes_in_group('unclaimed_items')
		for item in unclaimed:
			if item is OGItemBone:
				print('found a bone')
				item.was_claimed_by(self)
			
				var job = Job.new(item.location)
				job.worker = self
# warning-ignore:return_value_discarded
				connect('reached_end_of_path', job, 'do_next_step')
				return true
	return false
