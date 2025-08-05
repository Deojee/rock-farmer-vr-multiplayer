extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var UP = Vector3.UP

@export var isVr = false

func _ready():
	
	VRGlobals.player = self
	

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity += -UP * 9.8  * delta
	
	move_and_slide()
	
	#print(velocity)
	
	
