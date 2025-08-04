extends Node3D

var playerScene : String = "res://scenes/simplePlayer.tscn"

var spawnSyncNode : Node

#id to player
var playerData : Dictionary = {}

func _ready() -> void:
	spawnSyncNode = $syncNodeHolder
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)
	
	if Globals.is_server:
		add_player(multiplayer.get_unique_id(),VRGlobals.isVrMode)
		
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	

func _connected_to_server():
	rpc_id(Globals.SERVER_UNIQUE_ID,"add_player",multiplayer.get_unique_id(),VRGlobals.isVrMode)
	pass

func _peer_connected(id : int):
	if multiplayer.is_server() and id == Globals.SERVER_UNIQUE_ID:
		add_player(id, VRGlobals.isVrMode)

func _peer_disconnected(id : int):
	if multiplayer.is_server():
		remove_player(id)

#only called by server
@rpc("any_peer", "reliable")
func add_player(id,isVr):
	var newPlayer = load(playerScene).instantiate()
	newPlayer.name = str(id)
	
	spawnSyncNode.add_child(newPlayer)
	playerData[id] = [newPlayer]
	

#only called by server
func remove_player(id):
	
	if playerData[id]:
		playerData[id][0].queue_free()
	
	playerData.erase(id)
	
