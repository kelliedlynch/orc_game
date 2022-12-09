extends OGCreature
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
	
func _ready():
	
	$GOAPAgent.add_goals([
		GoalHoldBone.new(),
		GoalEntertainSelf.new(),
	])
#	$GOAPAgent.set_state_tracker($GOAPStateTracker)
	
	$GOAPAgent/GOAPPlanner.add_actions([
		ActionPickUpBone.new(),
		ActionWander.new(),
	])

