extends Node3D

const ejectionSpeed = 8

var spawnableScenes = [
	"res://scenes/items/tools/pickaxes/pickaxe_tier_1.tscn",
	
	
]

func _init() -> void:
	
	set_multiplayer_authority(Globals.SERVER_UNIQUE_ID)
	
	

#called by all peers but only the server actually does it.
func _on_hand_detector_area_entered(area: Area3D) -> void:
	
	print("dispensing!")
	
	if !is_multiplayer_authority():
		return
	
	if !%AnimationPlayer.is_playing():
		%AnimationPlayer.play("dispense")
	
	pass # Replace with function body.

func dispense():
	
	if !multiplayer.is_server():
		return
	
	var customSpawnData : CustomSpawnData = CustomSpawnData.new()
	
	spawnableScenes.shuffle()
	customSpawnData.scenePath = spawnableScenes.front()
	
	customSpawnData.authorityID = Globals.SERVER_UNIQUE_ID
	customSpawnData.propertiesToSet = {
		"position":$itemStart.global_position,
		"linear_velocity":$itemStart.global_basis.z * ejectionSpeed,
	}
	customSpawnData.functionsToCall = {
		#"scaleIn" : [],
	}
	
	Globals.spawner.askServerToSpawn(customSpawnData)
	
	pass
