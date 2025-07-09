extends XRController3D

@export var myVrPlayer : vrPlayer

func _physics_process(delta):
	
	if get_input("by_button"):
		myVrPlayer.reel(delta)
	
	
	
	pass

@onready var grappleCast : RayCast3D = $grappleCast

func _on_button_pressed(inputName):
	
	if inputName == "ax_button":
		myVrPlayer.UP = global_basis.z
		Globals.slowTime(0.1)
	
	if inputName == "trigger_click":
		Globals.slowTime(0.2)
		if grappleCast.is_colliding():
			myVrPlayer.toggleGrapple(grappleCast.get_collision_point())
			
	
	if inputName == "primary_click":
		XRServer.center_on_hmd(XRServer.DONT_RESET_ROTATION,true)
		
		print(name)
		
	
	pass # Replace with function body.


func _on_button_released(inputName):
	
	if inputName == "trigger_click":
		myVrPlayer.toggleGrapple(null)
		Globals.slowTime(0.2)
	
	pass # Replace with function body.
