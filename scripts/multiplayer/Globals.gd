extends Node

#displayed the the user, used for debugging.
#clients won't join servers that are the wrong version
var version := "1.0.0"

#multiplayer stuff
#set by multiplayer host client
var isAndroid := false

var multiplayerId := -1
var is_server : bool
var peer : ENetMultiplayerPeer
var myAddress := ""
var spawner : MultiplayerSpawner #set by the spawner.

const SERVER_UNIQUE_ID = 1

#data about the player
var nameTag : String
