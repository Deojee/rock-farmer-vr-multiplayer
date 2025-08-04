extends MarginContainer

var myEntry : LobbySyncer.LobbyListEntry
var myPanel : Lobby_panel

func _process(delta: float) -> void:
	
	if myPanel:
		%Button.disabled = !myPanel.readyToJoinSever
		
	else:
		%Button.disabled = true
	

func setData(data : LobbySyncer.LobbyListEntry,lobby_panel):
	myEntry = data
	myPanel = lobby_panel
	
	%Button.disabled = !myPanel.readyToJoinSever
	
	%Name.text = data.lobbyName
	%Address.text = data.address
	%Mode.text = data.mode
	%Players.text = str(data.currentPlayers,"/",data.maxPlayers)
	
	pass

func _on_button_pressed() -> void:
	print("trying to join server!")
	MultiplayerHostClientHandler.join_server(myEntry.address,myEntry.port)
	pass # Replace with function body.
