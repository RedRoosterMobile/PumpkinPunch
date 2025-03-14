extends PathFollow3D

@export var speed = 2.0  # Speed in units per second
var animation_player: AnimationPlayer
func _ready() -> void:
	
	animation_player=get_child(0).get_child(1)
func _process(delta):
	
	if progress <= 0.01:
		#Audio.play("audio/crazy_bat.ogg", true, global_transform)
		pass
	# Increase the progress along the path
	progress += speed * delta
	
	if (progress_ratio > 0.55):
		animation_player.play("ArmatureAction")
	
	#
	
	# Optional: Loop the path when the bat reaches the end
	if progress_ratio >= 0.99:
		print("resetting bat")
		animation_player.stop(false)
		progress = 0.0
		
		
