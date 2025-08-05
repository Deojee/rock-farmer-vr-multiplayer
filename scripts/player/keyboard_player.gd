extends Player


@export var cam : Camera3D


const SPRINT_SPEED = 9
const ACCEL = 5.0
const JUMP_FORCE = 7
const JUMP_CANCEL_SPEED = 20


var is_jumping = false

func _enter_tree() -> void:
	
	print("enter tree called ", multiplayer.get_unique_id())
	_setup(int(name))
	

func _ready() -> void:
	
	if is_multiplayer_authority():
		super._ready()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

var pause = false

func _process(delta: float) -> void:
	
	if !is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("pause"):
		
		pause = !pause
		
		if !pause:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	
	

func _physics_process(delta: float) -> void:
	
	if !is_multiplayer_authority():
		return
	
	# Get input direction vector in local space
	var input_dir = -Vector2(
		Input.get_axis("d", "a"),   # x-axis (left/right)
		  # y-axis (up/down)
		Input.get_axis("s", "w")    # z-axis (forward/backward)
	)
	
	
	# Transform input direction from local to global space using the basis
	var target : Vector3 = (input_dir.y * basis.z + input_dir.x * basis.x).normalized()
	
	
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
	
	super._physics_process(delta)
	

func _setup(myId):
	
	print("setting up ", myId)
	multiplayer.set_multiplayer_peer(Globals.peer)
	set_multiplayer_authority(myId)
	
	if is_multiplayer_authority():
		$nametag.text = Globals.nameTag + "\nID:" + str(myId)
		cam.current = true
		Globals.world.terrain3D.set_camera(cam)
	
	Globals.world.playerData[myId] = [self]
	

var sensX = 0.001
var sensY = 0.001

func _input(event: InputEvent) -> void:
	
	if pause or !is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		cam.rotate_x(-event.relative.y * sensY)
		rotation.y += -event.relative.x * sensX
		
	
