extends OGCreature
class_name OGCreatureOrc

onready var agent: AIAgent = AIAgent
onready var state_tracker: GOAPStateTracker = $GOAPStateTracker

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
	state_tracker.actor = self
	
	state_tracker.add_goals([
		GoalClaimBone.new(),
		GoalEntertainSelf.new(),
	])
	# TODO NEXT
	# Should probably convert Actions to singletons like I did with goals.
	# They're going to be executed the same way for every creature, I'm pretty sure.
	
	state_tracker.add_actions([
		ActionClaimBone.new(),
		ActionWander.new(),
		ActionConstructBuilt.new(),
	])

	state_tracker.add_skills([
		CreatureSkill.BUILDING,
		CreatureSkill.FARMING,
		CreatureSkill.FIGHTING,
		CreatureSkill.HAULING,
	])

func _run_agent():
	agent.run(self)
