extends CharacterBody3D


@export var cam : Camera3D

const SPEED = 6
const SPRINT_SPEED = 9
const ACCEL = 5.0
const JUMP_FORCE = 5000
const JUMP_CANCEL_SPEED = 20


static var INSTANCE

var is_jumping = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	INSTANCE = self

var pause = false

func _process(delta: float) -> void:
	
	
	velocity += get_gravity()
	
	if Input.is_action_just_pressed("pause"):
		
		pause = !pause
		
		if !pause:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	
	

func _physics_process(delta: float) -> void:
	
	
	
	# Get input direction vector in local space
	var input_dir = -Vector2(
		Input.get_axis("d", "a"),   # x-axis (left/right)
		  # y-axis (up/down)
		Input.get_axis("s", "w")    # z-axis (forward/backward)
	)
	
	
	# Transform input direction from local to global space using the basis
	var target : Vector3 = (input_dir.y * basis.z + input_dir.x * basis.x).normalized()
	
	print(target)
	
	if pause:
		target = Vector3.ZERO
	
	if Input.is_action_pressed("shift"):
		target *= SPRINT_SPEED
	else:
		target *= SPEED
	
	
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y += JUMP_FORCE
		is_jumping = true
	if Input.is_action_just_released("space") and velocity.y > JUMP_CANCEL_SPEED:
		velocity.y = JUMP_CANCEL_SPEED
		is_jumping = false
	if is_on_floor():
		is_jumping = false
	
	velocity.x = lerp(velocity.x,target.x, delta * ACCEL)
	velocity.z = lerp(velocity.z,target.z, delta * ACCEL)
	
	#position += velocity * delta * (1.0/Engine.time_scale)
	
	move_and_slide()
	
	
	



var sensX = 0.001
var sensY = 0.001

func _input(event: InputEvent) -> void:
	
	if pause:
		return
	
	if event is InputEventMouseMotion:
		cam.rotate_x(-event.relative.y * sensY)
		rotation.y += -event.relative.x * sensX
		
	
