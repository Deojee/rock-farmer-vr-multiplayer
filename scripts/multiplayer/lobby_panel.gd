extends Control

class_name Lobby_panel

var lobbyLineScene = preload("res://scenes/lobbyDataLine.tscn")

var playerNameLine : CensoredNameLine
var debugText : Label

#currently based on if the nametag is valid
var readyToJoinSever = false 

func _ready() -> void:
	
	playerNameLine = %playerNameLine
	debugText = %debugText
	
	LobbySyncer.fetch_lobbies()
	LobbySyncer.lobbies_updated.connect(_onLobbiesUpdated)

func _process(delta: float) -> void:
	
	
	debugText.text = MultiplayerHostClientHandler.debugText
	
	pass


func _onLobbiesUpdated(lobbies : Array):
	
	var lobbyLineHolder= %"Vbox lobbies"
	
	for child in lobbyLineHolder.get_children():
		child.queue_free()
	
	for lobby in lobbies:
		lobby = lobby as LobbySyncer.LobbyListEntry
		
		var newLine = lobbyLineScene.instantiate()
		newLine.setData(lobby,self)
		
		lobbyLineHolder.add_child(newLine)
		
	
	pass

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.


func _on_refresh_pressed() -> void:
	
	LobbySyncer.fetch_lobbies()
	
	pass # Replace with function body.

func _on_player_name_line_name_validity_changed(isValid : bool, playerName : String) -> void:
	
	if isValid:
		Globals.nameTag = playerName
	readyToJoinSever = isValid
	
