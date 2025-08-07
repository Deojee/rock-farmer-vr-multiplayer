extends RigidBody3D
class_name holdableItem

func _init() -> void:
	
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)
	
	

func _ready() -> void:
	
	if !multiplayer.is_server():
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	

func use(hand,body):
	pass

@export var handle : Node3D



const startScale = 0.1
const expandTime = 0.5
func scaleIn():
	
	scale = startScale * Vector3.ONE
	
	var tween = create_tween()
	
	tween.tween_property(self,"scale",Vector3.ONE,expandTime)
	
