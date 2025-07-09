extends Player
class_name vrPlayer

#most of the code is in the hands.


func _physics_process(delta):
	
	$pointer.look_at(
		global_position + 
		(-%camera.global_basis.z - UP * -%camera.global_basis.z.dot(UP))
		
		,UP
		)
	
	
	var targetVelocity = UP * velocity.dot(UP)
	
	#targetVelocity += Input.get_axis("w","s") * SPEED * global_basis.z
	#targetVelocity += Input.get_axis("a","d") * SPEED * global_basis.x
	
	if not is_on_floor():
		#velocity /= 1.01
		velocity = lerp(velocity,targetVelocity,0.2 * delta)
	else:
		velocity = lerp(velocity,targetVelocity,2 * delta)
	
	super._physics_process(delta)
	
