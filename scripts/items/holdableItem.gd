extends RigidBody3D
class_name holdableItem

#only set serverside.
var beingHeld = false:
	set(value):
		pass
	get:
		pass

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
	
	var tween = get_tree().create_tween()
	
	tween.tween_method(setScaleOfAllChildren,startScale,1,expandTime)
	
	

var lastScale : float = 1.0
func setScaleOfAllChildren(newScale : float):
	
	var scaleMultiplier = newScale/lastScale
	
	for child in get_children():
		if child is Node3D:
			
			child.scale *= scaleMultiplier
			child.position *= scaleMultiplier
			
	
	lastScale = newScale
	
