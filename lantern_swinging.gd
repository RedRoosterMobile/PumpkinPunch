extends Node3D

@onready var post_lantern_lantern: MeshInstance3D = $post_lantern/post_lantern_lantern

# Rotation speed multiplier
@export var rotation_speed: float = 1.0
# Maximum rotation angle in degrees
@export var max_angle: float = 5.0

# Time accumulator
var time: float = 0.0

func _process(delta: float) -> void:
	# Increment time with delta
	time += delta * rotation_speed
	
	# Calculate target rotation using sine (converting to radians)
	var target_rotation = deg_to_rad(sin(time) * max_angle)
	var target_rotation_z = deg_to_rad(cos(time) * max_angle/2)
	
	# Method 1: Set rotation directly (might cause jitter if combined with other rotations)
	#post_lantern_lantern.rotation.x = target_rotation
	
	# Method 2: Incremental rotation (better for smooth movement)
	# Reset rotation to 0 first, then apply new rotation
	post_lantern_lantern.rotation.x = 0
	post_lantern_lantern.rotate_x(target_rotation)
	post_lantern_lantern.rotation.z = 0
	post_lantern_lantern.rotate_z(target_rotation_z)
