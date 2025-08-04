extends Control

var port := 8010

var lobbyNameLine : CensoredNameLine
var playerNameLine : CensoredNameLine
var debugText : Label
var portLine : SpinBox

var startLobbyButton : Button

#this stores data about the lobby that will be shared.
var lobbyEntry = LobbySyncer.myEntry 

func _ready() -> void:
	lobbyNameLine = %lobbyNameLine
	playerNameLine = %playerNameLine
	startLobbyButton = %"start lobby"
	debugText = %debugText
	portLine = %portLine
	
	
	var randomPort = randi_range(portLine.min_value + 1,portLine.max_value - 1)
	portLine.value = randomPort
	LobbySyncer.myEntry.port = randomPort
	
	
	pass

func _process(delta: float) -> void:
	
	#can't start lobby without names!
	startLobbyButton.disabled = !(lobbyNameLine.isValid and playerNameLine.isValid)
	debugText.text = MultiplayerHostClientHandler.debugText
	
	pass

"""
var playerName = %nameTag.text
var censoredName = censorSwears(playerName)
Globals.nameTag = censoredName
"""


func _on_player_name_line_name_validity_changed(isValid : bool, playerName : String) -> void:
	
	if isValid:
		Globals.nameTag = playerName
	

func _on_lobby_name_line_name_validity_changed(isValid : bool, lobbyName : String) -> void:
	
	if isValid:
		LobbySyncer.myEntry.lobbyName = lobbyName
	

func _on_start_lobby_pressed() -> void:
	MultiplayerHostClientHandler.start_server()
	pass # Replace with function body.


func _on_max_players_line_value_changed(value: float) -> void:
	lobbyEntry.maxPlayers = value
	pass # Replace with function body.

func _on_port_line_value_changed(value: float) -> void:
	lobbyEntry.port = int(value)
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.
