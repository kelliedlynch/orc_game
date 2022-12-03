extends 'res://creatures/CreatureModel.gd'
class_name Orc

const CreatureType = preload('res://creatures/CreatureType.gd')

func _init():
	type = CreatureType.TYPE.HUMANOID
	subtype = CreatureType.SUBTYPE.ORC
	sprite_texture = load('res://creatures/orcs/orc_01.tres')

	first_name_complete = ['Grug', 'Thog', 'Grest', 'Ogor', 'Ogon', 'Krag', 'Patrick']
	first_name_syllable1 = ['Gr\'', 'Ku', 'Tak', 'Gor', 'Da', 'K\'', 'Bak']
	first_name_syllable2 = ['thor', 'brag', 'duk', 'thak', 'tar', 'gar', 'dar', 'deg']
	first_name_word1 = ['Snaggle', 'Rock', 'Green', 'Red', 'Yellow', 'Black', 'Crack', 'Gore', 'Dark', 'Sharp']
	first_name_word2 = ['tooth', 'tusk', 'fang', 'heart', 'gut', 'wart', 'fist', 'grin', 'grip']
	first_name = generate_first_name()
