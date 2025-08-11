extends Node3D

"""
handles daylight cycle. tells other things when it's day
only runs on server
"""

##length of full day/night cycle 
##in minutes is all these added together
##on earth, dawn and dusk are exactly 1/10th as long as day and night
const DAWN_LENGTH : float = (5.0/10.0)
const DAY_LENGTH : float = 5.0
const DUSK_LENGTH : float= (5.0/10.0)
const NIGHT_LENGTH : float = 5.0

#in degrees. 
const DAWN_START_ANGLE = -18 # 360 - 18
const DAY_START_ANGLE = 0
const DUSK_START_ANGLE = 180
const NIGHT_START_ANGLE = 198 # 180 + 18
const NIGHT_END_ANGLE = DAWN_START_ANGLE + 360 #dawn start angle but positive


const SECONDS_TO_MINUTES = 60

const FULL_DAY_LENGTH = DAWN_LENGTH + DAY_LENGTH + DUSK_LENGTH + NIGHT_LENGTH

enum SUN_POSITION {DAWN,DAY,DUSK,NIGHT}

##current time of day in seconds after dawn starts
##only synced variable in this script
@export var time : float 

##this is referenced by anything that needs to know the time of day
var current_sun_position : SUN_POSITION 



func _init() -> void:
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)

func _physics_process(delta: float) -> void:
	
	if multiplayer.is_server():
		time += delta * 60
		if time > FULL_DAY_LENGTH * SECONDS_TO_MINUTES:
			time = 0
		
	
	var time_minutes : float = time/SECONDS_TO_MINUTES
	
	var sun_angle : float
	
	if time_minutes <= DAWN_LENGTH:
		current_sun_position = SUN_POSITION.DAWN
		sun_angle = map(0,DAWN_LENGTH,DAWN_START_ANGLE,DAY_START_ANGLE,time_minutes)
		
	elif time_minutes <= DAWN_LENGTH + DAY_LENGTH:
		current_sun_position = SUN_POSITION.DAY
		sun_angle = map(DAWN_LENGTH,
						DAWN_LENGTH + DAY_LENGTH,
						DAY_START_ANGLE,
						DUSK_START_ANGLE,
						time_minutes)
		
	elif time_minutes <= DAWN_LENGTH + DAY_LENGTH + DUSK_LENGTH:
		current_sun_position = SUN_POSITION.DUSK
		sun_angle = map(DAWN_LENGTH + DAY_LENGTH,
						DAWN_LENGTH + DAY_LENGTH + DUSK_LENGTH,
						DUSK_START_ANGLE,
						NIGHT_START_ANGLE,
						time_minutes)
		
	elif time_minutes <= FULL_DAY_LENGTH:
		current_sun_position = SUN_POSITION.NIGHT
		sun_angle = map(DAWN_LENGTH + DAY_LENGTH + DUSK_LENGTH,
						FULL_DAY_LENGTH,
						NIGHT_START_ANGLE,
						NIGHT_END_ANGLE,
						time_minutes)
	
	var startRot = rotation.z
	
	rotation.z = deg_to_rad(sun_angle)
	
	var rotchange = rotation.z - startRot
	
	_applyLighting(sun_angle)
	
	prints(sun_angle,current_sun_position,time_minutes,rad_to_deg(rotchange))
	

@export var waterMesh : MeshInstance3D
@export var environment : WorldEnvironment
@export var lightSource : DirectionalLight3D

const MIN_ENERGY = 0.2
const MAX_ENGERY = 1.5

const NOON_ANGLE = 90.0
const DARKEST_ANGLE = -18
const MAX_LIT_ANGLE = abs(NOON_ANGLE) + abs(DARKEST_ANGLE)

func _applyLighting(sun_angle : float):
	
	var angleFromNoon = abs(sun_angle - NOON_ANGLE)
	
	var energy = map(0,MAX_LIT_ANGLE,MAX_ENGERY,MIN_ENERGY,angleFromNoon)
	
	energy = clamp(energy,MIN_ENERGY,MAX_ENGERY)
	
	environment.environment.background_energy_multiplier = energy
	lightSource.light_energy = energy
	waterMesh.material_override.set_shader_parameter("color_multiplier",energy)
	
	
	pass


func map(in_a,in_b,out_a,out_b,value):
	return (((value - in_a) * (out_b - out_a)) / (in_b - in_a)) + out_a
