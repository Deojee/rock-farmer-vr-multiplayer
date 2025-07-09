extends Node
class_name StateMachine

var state = null
var previousState = null
var states = {}

#for awaiting things. Prevents physics process from being called until it's true
var paused = false

var firstFrame = true

@onready var parent = get_parent()



"""
NOT meant to be overrided, but you could I guess. 
Calls state logic, transitions, and setstate if it needs to transition.
"""
func _physics_process(delta):
	if state != null and !paused:
		_stateLogic(delta)
		var newState = _getTransition(delta)
		if newState != null:
			setState(newState)
	
	if !firstFrame and state == null:
		print("hey, a state machine doesn't have a state!")
	
	firstFrame = false

#override functions from here

"""
You are intended to ovveride ready and add your states to it.
You also should set your starting state.
"""
func _ready():
	pass


"""
Virtual and run every frame. Should tell the parent what to do based on the state.
"""
func _stateLogic(delta):
	pass

"""
Virtual and run every frame. Should check what state the machine should turn to.
Returns the name of the state it should change to.
"""
func _getTransition(delta):
	pass

"""
Only called by setState. 
State has already been changed, this checks for special conditions.
"""
func _enterState(newState,oldState):
	pass

"""
Only called by setState. 
State has already been changed, this checks for special conditions.
"""
func _exitState(oldState,newState):
	pass

#to here

"""
The only way to change state.
Should only be called by _getTransition()
"""
func setState(newState):
	previousState = state
	state = newState
	
	if previousState != null:
		_exitState(previousState,state)
	if state != null:
		_enterState(state,previousState)
	

"""
Adds a state to the state dictionary, this doesn't 
"""
func addState(newState : String):
	states[newState] = states.size()
