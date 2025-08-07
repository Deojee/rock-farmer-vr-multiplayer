extends Node3D

#a reference to whatever owns this hand
@export var body : Node

@export var isVr = false

@export var xrController : XRController3D = null



var heldObject : RigidBody3D = null 

var originialRotation : Basis
var originalOffset : Vector3

func _init() -> void:
	
	#the player already set the authority for us.
	
	pass
	


var ownerId : int

func _ready():
	pass
	

##synced between authority and server
##set only by authority
@export var holdPressed : bool = false 

var holdPressedLastFrame = false #calculated on both authority and server

func _physics_process(delta):
	
	if is_multiplayer_authority():
		
		handleInputs() #these are handled by the owner and then synced with the server
		getClosestItem()
	
	if !multiplayer.is_server():
		return
	
	var holdJustPressed = holdPressed and !holdPressedLastFrame
	
	var closestItem = getClosestItem()
	
	
	if closestItem and !heldObject and holdJustPressed:
		
		pickUp(closestItem)
		
	elif !holdPressed:
		heldObject = null
	
	
	if heldObject and multiplayer.is_server():
		handleHeldItem(delta)
	
	holdPressedLastFrame = holdPressed
	
	
	

#called by authority only
func handleInputs():
	
	if isVr:
		
		holdPressed = (xrController and xrController.get_float("grip"))
		
	else:
		
		if Input.is_action_just_pressed("mouseRight"):
			holdPressed = !holdPressed
		
		
	
	pass

#only called by server
func pickUp(item):
	heldObject = item
	
	# we want the our global matrix as relative to the object
	var m = (heldObject.global_transform.affine_inverse() * 
	global_transform)
	
	#print(m)
	originalOffset = m.origin * 0.9 #we allow for an offset but it's not a large one
	originialRotation = m.basis

#called by authority and server
#authority only uses it for showing the pickup icon
func getClosestItem():
	
	var items = $itemsDetect.get_overlapping_bodies()
	
	for item in items:
		if !item is RigidBody3D:
			items.erase(item)
	
	if items.size() < 1:
		$targetIcon.visible = false
		return null
	
	
	var closestDistance = global_position.distance_to(items[0].global_position)
	var closestItem = items[0]
	
	for item in items:
		
		if !item.is_inside_tree():
			continue
		
		var distance = global_position.distance_to(item.global_position)
		if distance <= closestDistance:
			closestDistance = distance
			closestItem = item
			
			
	
	if !holdPressed and is_multiplayer_authority():
		
		$targetIcon.visible = true
		$targetIcon.global_position = closestItem.global_position
		$targetIcon.global_rotation = Vector3.ZERO
		
	else:
		$targetIcon.visible = false
		
	
	return closestItem
	

#called by server only
func handleHeldItem(delta):
	
	if !heldObject.is_visible_in_tree():
		heldObject = null
		
	
	#the handle is the position and rotation in space the object is held by
	var handle : Transform3D = heldObject.global_transform
	handle = handle.translated_local(originalOffset)
	handle.basis *= originialRotation
	
	if heldObject is holdableItem: #if it has a handle we ignore it's starting rotation and position
		handle = heldObject.handle.global_transform
	
	var target_transform : Transform3D = global_transform
	var current_transform : Transform3D = handle
	var rotation_difference : Basis = (target_transform.basis * current_transform.basis.inverse())

	var position_difference : Vector3 = target_transform.origin - current_transform.origin
	
	#if position_difference.length_squared() > 1.0:
		#heldObject.global_position = target_transform.origin
	#else:
	var force: Vector3 = hookes_law(position_difference, heldObject.linear_velocity, linear_spring_stiffness, linear_spring_damping)
	force = force.limit_length(max_linear_force)
	heldObject.linear_velocity += (force * delta)
	
	var torque = hookes_law(rotation_difference.get_euler(), heldObject.angular_velocity, angular_spring_stiffness, angular_spring_damping)
	torque = torque.limit_length(max_angular_force)
	
	
	heldObject.angular_velocity += torque * delta
	
	pass


@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
