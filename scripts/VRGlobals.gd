extends Node

static var INSTANCE : VRGlobals

static var isVrMode = true


static var player : Player # set by player selector
static var xr_interface: XRInterface

func _ready():
	
	INSTANCE = self
	
	if !isVrMode:
		return
	
	#print(XRServer.get_interfaces())
	
	xr_interface = XRServer.get_interface(1)
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		
		#Engine.set_physics_ticks_per_second(DisplayServer.screen_get_refresh_rate())

	else:
		isVrMode = false
		print("OpenXR not initialized, please check if your headset is connected")
	
func _physics_process(delta):
	
	#Engine.time_scale *= 1 + (Engine.physics_ticks_per_second * delta)/Engine.time_scale * 0.03
	#Engine.time_scale = min(1,Engine.time_scale)
	
	#print(Engine.time_scale)
	pass

func slowTime(newTimeScale):
	Engine.time_scale = newTimeScale
	pass


func playerRequestsReset():
	
	pass
