extends XRController3D

@export var myVrPlayer : vrPlayer

func _physics_process(delta):
	
	if get_input("by_button"):
		pass
	
	
	
	pass

@onready var grappleCast : RayCast3D = $grappleCast

func _on_button_pressed(inputName):
	
	if inputName == "ax_button":
		
		pass
	
	if inputName == "trigger_click":
		
		pass
	
	if inputName == "primary_click":
		XRServer.center_on_hmd(XRServer.DONT_RESET_ROTATION,true)
		
		print(name)
		
	
	pass # Replace with function body.


func _on_button_released(inputName):
	
	if inputName == "trigger_click":
		pass
	
