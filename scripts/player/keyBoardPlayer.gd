extends Player



func _physics_process(delta):
	
	
	if Input.is_action_just_pressed("mouseLeft"):
		UP = neck.global_basis.z.normalized()
	
	
	var targetVelocity = UP * velocity.dot(UP)
	
	targetVelocity += Input.get_axis("w","s") * SPEED * global_basis.z
	targetVelocity += Input.get_axis("a","d") * SPEED * global_basis.x
	
	if not is_on_floor():
		#velocity /= 1.01
		velocity = lerp(velocity,targetVelocity,0.2 * delta)
	else:
		velocity = lerp(velocity,targetVelocity,2 * delta)
	
	if Input.is_action_just_pressed("space"):
		velocity += JUMP_VELOCITY * UP
	
	
	
	
	super._physics_process(delta)
	
	


@onready var grappleCast = %grapplingCast



@onready var neck = $neck

var sensitivity = 0.003
func _input(event):
	
	if event is InputEventMouseMotion:
		
		rotate(UP,event.relative.x * -sensitivity)
		
		neck.rotate_x(event.relative.y * -sensitivity)
		
		neck.rotation_degrees.x = clamp(neck.rotation_degrees.x,-90,90)
		
	pass
	
