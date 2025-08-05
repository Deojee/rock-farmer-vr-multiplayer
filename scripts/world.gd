extends Node3D

class_name World

var keyboardPlayerScene : String = "res://scenes/keyboard_player.tscn"
var vrPlayerScene : String = "res://scenes/vr_player.tscn"

@export var playerSpawnPoint : Marker3D 

var spawnSyncNode : Node

#id to player
var playerData : Dictionary = {}

func _ready() -> void:
	Globals.world = self
	
	spawnSyncNode = $multiplayerSync
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)
	
	if Globals.is_server:
		add_player(multiplayer.get_unique_id(),VRGlobals.isVrMode)
	else:
		print("Asking for avatar ",multiplayer.get_unique_id())
		rpc_id(
			Globals.SERVER_UNIQUE_ID,
			"add_player",multiplayer.get_unique_id(),
			VRGlobals.isVrMode
			)
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	
	

func _connection_failed():
	
	print("connection failed ",multiplayer.get_unique_id())
	

func _connected_to_server():
	pass

func _peer_connected(id : int):
	if multiplayer.is_server():
		print("Peer Connected")
	pass

func _peer_disconnected(id : int):
	if multiplayer.is_server():
		remove_player(id)

#only called by server
@rpc("any_peer", "reliable")
func add_player(id,isVr):
	
	
	var customSpawnData : CustomSpawnData
	
	if isVr:
		customSpawnData.scenePath = load(vrPlayerScene).instantiate()
	else:
		customSpawnData.scenePath = load(keyboardPlayerScene).instantiate()
	
	customSpawnData.authorityID = id
	customSpawnData.propertiesToSet = {
		"name":str(id),
		"global_position":playerSpawnPoint.global_position,
	}
	
	
	
	
	Globals.spawner.askServerToSpawn(customSpawnData)
	

#only called by server
func remove_player(id):
	
	if playerData[id]:
		playerData[id][0].queue_free()
	
	playerData.erase(id)
	
