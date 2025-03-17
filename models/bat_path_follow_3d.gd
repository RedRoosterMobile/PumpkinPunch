extends PathFollow3D

@export var speed = 2.0  # Speed in units per second
var animation_player: AnimationPlayer
var is_moving = false  # Flag to control movement
@onready var follower: Node3D = $Follower

func _ready() -> void:
	animation_player = get_child(0).get_child(0).get_child(1)
	# Connect to the global Messenger signal
	Messenger.spawn_big_bat.connect(spawn)
	# Start with progress at 0 and not moving
	progress_ratio = 0.0

func _process(delta):
	if not is_moving:
		return
	
	# Increase the progress along the path when moving
	progress += speed * delta
	
	if progress_ratio > 0.55 and not animation_player.is_playing():
		# Play wing flap animation
		animation_player.play("ArmatureAction")
	
	# Stop at the end instead of looping
	if progress_ratio >= 0.99:
		stop_bat()

func spawn():
	# Start the bat movement when signal is received
	is_moving = true
	progress_ratio = 0.0  # Reset to start position
	follower.visible = true
	# Optional: Play any initial sound here if needed
	# Audio.play("audio/crazy_bat.ogg", true, global_transform)

func stop_bat():
	follower.visible = false
	# Stop the bat movement and animation
	is_moving = false
	animation_player.stop(false)
	progress_ratio = 1.0  # Ensure it's at the end
