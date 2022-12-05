extends Node

# Listed in priority--currently if tile qualifies for multiple terrains, the first in
# this dict will be chosen
const RegionParameters = {
	RegionType.Type.REGION_OCEAN: {
		'generation_parameters': {
			'max_elevation': -0.07,
		},
		'tile_types': {
			'base_tile_types': [
				TileType.Type.TILE_WATER,
			],
			'secondary_tile_types': [
				TileType.Type.TILE_WATER,
			]
		},	
	},
	RegionType.Type.REGION_DESERT: {
		'generation_parameters': {
			'max_soil_quality': -0.4,
			'max_precipitation': -0.4,
			'min_temperature': 0.4,
		},
		'tile_types': {
			'base_tile_types': [
				TileType.Type.TILE_DIRT,
			],
			'secondary_tile_types': [
				TileType.Type.TILE_GRASS,
			]
		},
	},
	RegionType.Type.REGION_ROCKY: {
		'generation_parameters': {
			'max_soil_quality': -0.4,
		},
		'tile_types': {
			'base_tile_types': [
				TileType.Type.TILE_DIRT,
			],
			'secondary_tile_types': [
				TileType.Type.TILE_GRASS,
			]
		},	
	},
	RegionType.Type.REGION_JUNGLE: {
		'generation_parameters': {
			'min_soil_quality': 0.2,
			'min_precipitation': 0.5,
			'min_temperature': 0.5,
		},
		'tile_types': {
			'base_tile_types': [
				TileType.Type.TILE_DIRT,
			],
			'secondary_tile_types': [
				TileType.Type.TILE_GRASS,
			]
		},	
	},
	RegionType.Type.REGION_TEMPERATE: {
		'generation_parameters': {
			'min_soil_quality': -0.5,
			'min_precipitation': -0.5,
			'max_precipitation': 0.5,
			'min_temperature': -0.5,
			'max_temperature': 0.5,
		},
		'tile_types': {
			'base_tile_types': [
				TileType.Type.TILE_DIRT,
			],
			'secondary_tile_types': [
				TileType.Type.TILE_GRASS,
			]
		},	
	},
}
