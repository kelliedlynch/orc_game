extends Node

const Item = {
	'ALL_ITEMS': 'all_items',
	'UNTAGGED_ITEMS': 'untagged_items', # Items not currently tagged by a creature
	'TAGGED_ITEMS': 'tagged_items', # Items currently tagged by a creature (is this necessary?)
	'OWNED_ITEMS': 'owned_items', # Items currently owned by a creature (is this necessary?)
	'UNOWNED_ITEMS': 'unowned_items', # Items currently not owned by a creature
	'AVAILABLE_ITEMS': 'available_items', # Items not currently owned, tagged, or prohibited
}

const Creature = {
	'LOOKING_FOR_BONE': 'looking_for_bone',
}

const Built = {
	'MEETING_PLACES': 'meeting_places',
}

const Jobs = {
	'INACTIVE_JOBS': 'inactive_jobs',
	'ACTIVE_JOBS': 'active_jobs',
}
