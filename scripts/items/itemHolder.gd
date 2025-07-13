extends Node3D

#a reference to whatever owns this hand
@export var body : Node

@export var isVr = false

@export var xrController : XRController3D = null



var heldObject : RigidBody3D = null 

var originialRotation : Basis
var originalOffset : Vector3


func _ready():
	pass
	

var vrHoldPressedLastFrame = false
var vrShootPressedLastFrame = false
func _physics_process(delta):
	
	
	var closestItem = getClosestItem()
	print(closestItem)
	
	#var holdPressed = Input.is_action_pressed("right_click") or (xrController and xrController.get_float("grip"))
	
	var shootTeleport = Input.is_action_just_pressed("mouseRight") or (xrController and xrController.is_button_pressed("trigger_click"))
	
	
	
	if isVr:
		#if !holdPressedLastFrame and holdPressed and closestItem and !heldObject:
		#if !holdPressed and holdPressedLastFrame and heldObject:
		var holdPressed = Input.is_action_just_pressed("mouseRight") or (xrController and xrController.get_float("grip"))
		var holdJustPressed = !vrHoldPressedLastFrame and holdPressed
		
		if holdJustPressed and closestItem and !heldObject:
			pickUp(closestItem)
		elif !holdPressed and heldObject:
			heldObject = null
		
		vrHoldPressedLastFrame = holdPressed
	else:
		var holdJustPressed = Input.is_action_just_pressed("mouseRight")
		if holdJustPressed and closestItem and !heldObject:
			pickUp(closestItem)
		elif holdJustPressed and heldObject:
			heldObject = null
	
	
	
	
	if heldObject:
		
		
		handleHeldItem(delta)
		
		if heldObject is holdableItem:
			if !isVr:
				pass
			elif xrController:#checks for controller here
				pass
	
	vrShootPressedLastFrame = shootTeleport
	

func pickUp(item):
	heldObject = item
	
	# we want the our global matrix as relative to the object
	var m = (heldObject.global_transform.affine_inverse() * 
	global_transform)
	
	#print(m)
	originalOffset = m.origin * 0.9 #we allow for an offset but it's not a large one
	originialRotation = m.basis

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
			
			
	
	if heldObject == null:
		$targetIcon.visible = true
		$targetIcon.global_position = closestItem.global_position
		$targetIcon.global_rotation = Vector3.ZERO
		
	else:
		$targetIcon.visible = false
		
	
	return closestItem
	

func handleHeldItem(delta):
	
	if !heldObject.is_visible_in_tree():
		heldObject = null
		
	
	
	#the handle is the position and rotation in space the object is held by
	var handle : Transform3D = heldObject.global_transform
	handle = handle.translated_local(originalOffset)
	handle.basis *= originialRotation
	
	#print(originalOffset)
	#handle.basis =  handle.basis * originialRotation
	
	if heldObject is holdableItem:
		handle = heldObject.handle.global_transform
	
	var target_transform: Transform3D = global_transform
	var current_transform: Transform3D = handle
	var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())

	var position_difference:Vector3 = target_transform.origin - current_transform.origin
	
	if position_difference.length_squared() > 1.0:
		heldObject.global_position = target_transform.origin
	else:
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
