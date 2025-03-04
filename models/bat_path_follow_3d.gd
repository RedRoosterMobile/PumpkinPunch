extends PathFollow3D

@export var speed = 2.0  # Speed in units per second

func _process(delta):
	
	if progress <= 0.01:
		#Audio.play("audio/crazy_bat.ogg", true, global_transform)
		pass
		
	# Increase the progress along the path
	progress += speed * delta
	
	# Optional: Loop the path when the bat reaches the end
	if progress_ratio >= 1.0:
		progress = 0.0
