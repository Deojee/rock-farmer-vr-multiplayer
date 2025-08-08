extends Node3D

"""
handles daylight cycle. tells other things when it's day
only runs on server
"""

##length of full day/night cycle 
##in minutes is all these added together
const DAWN_LENGTH = 2
const DAY_LENGTH = 4
const DUSK_LENGTH = 2
const NIGHT_LENGTH = 5

const FULL_DAY_LENGTH = DAWN_LENGTH + DAY_LENGTH + DUSK_LENGTH + NIGHT_LENGTH

enum SUN_POSITION {DAWN,DAY,DUSK,NIGHT}

func _init() -> void:
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)

func _physics_process(delta: float) -> void:
	
	if !multiplayer.is_server():
		return
	
	pass
