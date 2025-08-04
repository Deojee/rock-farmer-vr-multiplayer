extends Node

"""
Handles creating and joining servers
most communication with lobby syncer is elsewhere.
"""

var gameScene : PackedScene = preload("res://scenes/world.tscn")

var debugText = "Version: " + Globals.version

# Called when the node enters the scene tree for the first time.
func _ready():
	
	match OS.get_name():
		"Windows":
			Globals.myAddress = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
		"macOS":
			Globals.myAddress = get_local_ipv4_address()
		"Android":
			Globals.myAddress = get_local_ipv4_address()
			Globals.isAndroid = true
		
	
	LobbySyncer.myEntry.address = Globals.myAddress
	
	multiplayer.connected_to_server.connect(connectedToServer)
	multiplayer.connection_failed.connect(failedToConnect)
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)

func get_local_ipv4_address() -> String:
	# Check all available network interfaces
	var interfaces = IP.get_local_interfaces()
	for i in interfaces:
		for interface in i["addresses"]:
			# Filter out local loopback addresses (127.x.x.x)
			if is_valid_ipv4(interface) and not interface.begins_with("127"):
				return interface
	
	return ""

# Custom function to check if the string is a valid IPv4 address
func is_valid_ipv4(ip: String) -> bool:
	var octets = ip.split(".")
	if octets.size() != 4:
		return false
	
	for octet in octets:
		var num = int(octet)
		if num < 0 or num > 255:
			return false
	
	return true


func start_server():
	
	Globals.peer = ENetMultiplayerPeer.new()
	
	var error : Error = Globals.peer.create_server(LobbySyncer.myEntry.port,LobbySyncer.myEntry.maxPlayers)
	
	if error != OK:
		print(error)
		debugText = "Error starting server: " + str(error)
		return
	else:
		debugText = "Starting server!"
		print("Starting server!")
	
	multiplayer.set_multiplayer_peer(Globals.peer)
	
	get_tree().change_scene_to_packed(gameScene)
	
	Globals.multiplayerId = 1
	
	Globals.is_server = true
	
	LobbySyncer.begin_beating()
	

func join_server(address : String,port : int):
	
	Globals.peer = ENetMultiplayerPeer.new()
	
	var err = Globals.peer.create_client(address,port)
	multiplayer.multiplayer_peer = Globals.peer
	
	debugText = "Awaiting connection on port " + str(port) + " at " + address
	

func connectedToServer():
	Globals.multiplayerId = multiplayer.get_unique_id()
	Globals.is_server = false
	
	get_tree().change_scene_to_packed(gameScene)
	

func failedToConnect():
	print("server does not exist")

func peer_connected(peerId : int):
	
	if multiplayer.is_server():
		LobbySyncer.myEntry.currentPlayers = multiplayer.get_peers().size()
		
		pass
	
	pass

func peer_disconnected(peerId : int):
	
	if multiplayer.is_server():
		LobbySyncer.myEntry.currentPlayers = multiplayer.get_peers().size()
		
	
	pass
