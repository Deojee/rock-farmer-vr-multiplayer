extends Node3D

func _ready() -> void:
	
	var tween = get_tree().create_tween()
	
	

	tween.tween_callback($AnimationPlayer.play.bind("boat in")).set_delay(1)
	tween.tween_callback($AnimationPlayer.play.bind("boat out")).set_delay(55)
	tween.tween_callback(self._ready).set_delay(40)

	
	
