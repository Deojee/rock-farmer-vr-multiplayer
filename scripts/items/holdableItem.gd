extends RigidBody3D
class_name holdableItem

func _init() -> void:
	
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)
	
	

func _ready() -> void:
	
	if !multiplayer.is_server():
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	scaleIn()
	

func use(hand,body):
	pass

@export var handle : Node3D



const startScale = 0.01
const expandTime = 0.25
func scaleIn():
	
	
	for child in get_children():
		if child is MeshInstance3D:
			
			var childStartScale = child.scale
			child.scale = startScale * childStartScale
			
			var tween = get_tree().create_tween()
			
			tween.tween_property(child,"scale",childStartScale,expandTime)
			
