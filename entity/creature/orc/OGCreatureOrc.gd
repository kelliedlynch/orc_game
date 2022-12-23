extends OGSentientCreature
class_name OGCreatureOrc


#onready var state_tracker: GOAPStateTracker = $GOAPStateTracker

func _init():
	type = Creature.Type.TYPE_HUMANOID
	subtype = Creature.Subtype.SUBTYPE_ORC

	var generator = load('res://entity/creature/NameGenerator.tres')
	first_name = generator.generate_first_name()
	
func _ready():
#	state_tracker.actor = self
	
	goals = [
		GoalClaimBone.new(),
		GoalEntertainSelf.new(),
		GoalFeedSelf.new(),
	]
	for goal in goals:
#		goal.assign_to_creature(self)
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

	skills = [
		Creature.Skill.BUILDING,
		Creature.Skill.FARMING,
		Creature.Skill.FIGHTING,
		Creature.Skill.HAULING,
	]

func _run_agent():
	agent.run(self)
