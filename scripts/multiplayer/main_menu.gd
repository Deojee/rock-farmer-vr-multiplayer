extends Control


func _on_create_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer/lobby_creation_panel.tscn")
	pass # Replace with function body.


func _on_join_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer/lobby_panel.tscn")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit(0)
	pass # Replace with function body.


func _on_quick_start_pressed() -> void:
	
	
	var time = Time.get_datetime_dict_from_system()
	LobbySyncer.myEntry.lobbyName = "Lobby " + str(
		time["hour"],":",
		time["minute"] if 
		time["minute"] >= 10 else 
		"0" + str(time["minute"]))
	
	LobbySyncer.myEntry.port = 8010 + time["second"]
	Globals.nameTag = "Test_Name"
	
	
	MultiplayerHostClientHandler.start_server()
	pass # Replace with function body.
