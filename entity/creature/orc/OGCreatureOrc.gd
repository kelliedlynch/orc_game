extends OGCreature
class_name OGCreatureOrc

onready var agent: AIAgent = AIAgent
onready var state_tracker: GOAPStateTracker = $GOAPStateTracker

func _init():
	type = Creature.Type.TYPE_HUMANOID
	subtype = Creature.Subtype.SUBTYPE_ORC

	first_name_complete = ['Grug', 'Thog', 'Grest', 'Ogor', 'Ogon', 'Krag', 'Patrick']
	first_name_syllable1 = ['Gr\'', 'Ku', 'Tak', 'Gor', 'Da', 'K\'', 'Bak']
	first_name_syllable2 = ['thor', 'brag', 'duk', 'thak', 'tar', 'gar', 'dar', 'deg']
	first_name_word1 = ['Snaggle', 'Rock', 'Green', 'Red', 'Yellow', 'Black', 'Crack', 'Gore', 'Dark', 'Sharp']
	first_name_word2 = ['tooth', 'tusk', 'fang', 'heart', 'gut', 'wart', 'fist', 'grin', 'grip']
	first_name = generate_first_name()
	
func _ready():
	state_tracker.actor = self
	
	goals = [
		GoalClaimBone.new(),
		GoalEntertainSelf.new(),
		GoalFeedSelf.new(),
	]
	for goal in goals:
		goal.assign_to_creature(self)
		add_child(goal)
	
	actions = [
		ActionOwnItem.new(),
		ActionWander.new(),
		ActionConstructBuilt.new(),
		ActionPickUpItem.new(),
		ActionEatFood.new(),
	]
	for act in actions:
		act.creature = self
		add_child(act)

	state_tracker.add_skills([
		Creature.Skill.BUILDING,
		Creature.Skill.FARMING,
		Creature.Skill.FIGHTING,
		Creature.Skill.HAULING,
	])

func _run_agent():
	agent.run(self)
