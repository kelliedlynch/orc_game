extends Object

enum SUBTYPE {
	ORC,
	DWARF,
}

enum TYPE {
	HUMANOID,
	BEAST,
}

const TypeTree = {
	TYPE.HUMANOID: [
		SUBTYPE.ORC,
		SUBTYPE.DWARF,
	]
}
