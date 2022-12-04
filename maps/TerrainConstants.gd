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
	WATER,
}

# Listed in priority--currently if tile qualifies for multiple terrains, the first in
# this dict will be chosen
const REGION_PARAMETERS = {
	REGION_TYPE.OCEAN: {
		'generation_parameters': {
			'max_elevation': -0.07,
		},
		'tile_types': {
			'base_tile_types': [
				TILE_TYPE.WATER,
			],
			'secondary_tile_types': [
				TILE_TYPE.WATER,
			]
		},	
	},
	REGION_TYPE.DESERT: {
		'generation_parameters': {
			'max_soil_quality': -0.4,
			'max_precipitation': -0.4,
			'min_temperature': 0.4,
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
			'max_soil_quality': -0.4,
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
			'min_soil_quality': 0.2,
			'min_precipitation': 0.5,
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
			'min_soil_quality': -0.5,
			'min_precipitation': -0.5,
			'max_precipitation': 0.5,
			'min_temperature': -0.5,
			'max_temperature': 0.5,
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
