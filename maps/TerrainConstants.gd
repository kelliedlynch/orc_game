extends Object

enum REGION_TYPE {
	DESERT,
	ROCKY,
	TEMPERATE,
	JUNGLE,
	OCEAN
}

enum TILE_TYPE {
	GRASS,
	DIRT,
}

# Listed in priority--currently if tile qualifies for multiple terrains, the first in
# this dict will be chosen
const REGION_PARAMETERS = {
	REGION_TYPE.OCEAN: {
		'generation_parameters': {
			'max_elevation': 0.0,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.DIRT,
			],
			'secondary_tile_types': [
				TILE_TYPE.GRASS,
			]
		},	
	},
	REGION_TYPE.DESERT: {
		'generation_parameters': {
			'max_soil_quality': 0.3,
			'max_precipitation': 0.3,
			'min_temperature': 0.55,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.DIRT,
			],
			'secondary_tile_types': [
				TILE_TYPE.GRASS,
			]
		},
	},
	REGION_TYPE.ROCKY: {
		'generation_parameters': {
			'max_soil_quality': 0.4,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.DIRT,
			],
			'secondary_tile_types': [
				TILE_TYPE.GRASS,
			]
		},	
	},
	REGION_TYPE.JUNGLE: {
		'generation_parameters': {
			'min_soil_quality': 0.5,
			'min_precipitation': 0.75,
			'min_temperature': 0.5,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.DIRT,
			],
			'secondary_tile_types': [
				TILE_TYPE.GRASS,
			]
		},	
	},
	REGION_TYPE.TEMPERATE: {
		'generation_parameters': {
			'min_soil_quality': 0.4,
			'min_precipitation': 0.4,
			'max_precipitation': 0.8,
			'min_temperature': -0.2,
			'max_temperature': 0.8,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.DIRT,
			],
			'secondary_tile_types': [
				TILE_TYPE.GRASS,
			]
		},	
	},
}
