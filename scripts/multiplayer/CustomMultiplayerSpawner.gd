extends MultiplayerSpawner

func _ready() -> void:
	Globals.spawner = self
	
	spawn_function = customSpawnFunction
	
	
	pass

func askServerToSpawn(data : CustomSpawnData):
	if multiplayer.is_server():
		spawn(data.to_dict())
	else:
		rpc_id(Globals.SERVER_UNIQUE_ID,"_askServerToSpawn",data.to_dict())
	pass

@rpc("any_peer", "reliable")
func _askServerToSpawn(data : Dictionary):
	
	spawn(data)
	

func customSpawnFunction(data : Variant):
	
	data = data as Dictionary
	var spawnData = CustomSpawnData.from_dict(data)
	
	var node = spawnData.makeNode()
	
	return node
