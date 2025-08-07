extends RefCounted
class_name CustomSpawnData

var scenePath: String
var authorityID: int
var propertiesToSet: Dictionary #string : variant
var functionsToCall: Dictionary #string : Array

func _init(scene := "", authority := 1, _props := {}, _funcs := {}):
	scenePath = scene
	authorityID = authority
	propertiesToSet = _props
	functionsToCall = _funcs

func makeNode() -> Node:
	var newNode: Node = load(scenePath).instantiate()
	
	for key in propertiesToSet:
		newNode.set(key, propertiesToSet[key])
	
	for key in functionsToCall:
		newNode.callv(key, functionsToCall[key])
	
	return newNode

func to_dict() -> Dictionary:
	return {
		"scenePath": scenePath,
		"authorityID": authorityID,
		"propertiesToSet": propertiesToSet,
		"functionsToCall": functionsToCall,
	}

static func from_dict(dict: Dictionary) -> CustomSpawnData:
	var instance := CustomSpawnData.new()
	instance.scenePath = dict.get("scenePath", "")
	instance.authorityID = dict.get("authorityID", 1)
	instance.propertiesToSet = dict.get("propertiesToSet", {})
	instance.functionsToCall = dict.get("functionsToCall", {})
	return instance
