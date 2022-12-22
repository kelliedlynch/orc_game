extends Object

func generate_first_name() -> String:
	var method2_chance = max(first_name_syllable1.size() - 1, first_name_syllable2.size() - 1)
	var method3_chance = max(first_name_word1.size() - 1, first_name_word2.size() -1)
	var methods = first_name_complete.size() - 1 + method2_chance + method3_chance
	var method = randi() % methods
	var _first: Array
	var _second: Array
	if method < first_name_complete.size():
		return first_name_complete[method]
	elif method >= method2_chance and method < method3_chance:
		_first = first_name_syllable1
		_second = first_name_syllable2
	else:
		_first = first_name_word1
		_second = first_name_word2
	return _first[randi() % (_first.size() - 1)] + _second[randi() % (_second.size() - 1)]
	
# Name generator variables to be set by creature type/subtype
var first_name_complete: Array = ['Grug', 'Thog', 'Grest', 'Ogor', 'Ogon', 'Krag', 'Patrick']
var first_name_syllable1: Array = ['Gr\'', 'Ku', 'Tak', 'Gor', 'Da', 'K\'', 'Bak']
var first_name_syllable2: Array = ['thor', 'brag', 'duk', 'thak', 'tar', 'gar', 'dar', 'deg']
var first_name_word1: Array = ['Snaggle', 'Rock', 'Green', 'Red', 'Yellow', 'Black', 'Crack', 'Gore', 'Dark', 'Sharp']
var first_name_word2: Array = ['tooth', 'tusk', 'fang', 'heart', 'gut', 'wart', 'fist', 'grin', 'grip']
