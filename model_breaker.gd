extends Node3D

@export var INTENSITY: float = 4.0
@export var RANDOMNESS: float = 0.5  # Controls how much random deviation (0.0 = none, 1.0 = lots)
var shot_direction: Vector3   # Direction from which the pumpkin was shot

func _ready() -> void:
	# Normalize shot_direction if it's been set, otherwise use default
	if shot_direction != Vector3.ZERO:
		shot_direction = shot_direction.normalized()
	else:
		shot_direction = Vector3.UP  # Default direction if none specified
	
	#self.scale = Vector3(0.5, 0.5, 0.5)  # Reset parent scale
	#print("Adjusted parent scale: ", self.scale)
	
	for piece in self.get_children():
		# Base direction from piece position
		var base_dir = piece.get_child(0).position.normalized()
		#piece.scale_object_local(Vector3(0.1,0.1,0.1))
		# piece.scale*=0.1
		# Add influence from shot direction
		base_dir = base_dir.lerp(shot_direction, 0.3)  # Mix in some shot direction
		
		# Add random variation
		var random_offset = Vector3(
			randf_range(-RANDOMNESS, RANDOMNESS),
			randf_range(-RANDOMNESS, RANDOMNESS),
			randf_range(-RANDOMNESS, RANDOMNESS)
		)
		
		# Combine and normalize the final direction
		var final_direction = (base_dir + random_offset).normalized()
		
		# Apply impulse with random intensity
		var random_intensity = INTENSITY * randf_range(0.8, 1.2)
		piece.apply_impulse(final_direction * random_intensity, self.global_position)
	
	# Optional: Add random angular velocity for spinning pieces
		piece.angular_velocity = Vector3(
			randf_range(-2.0, 2.0),
			randf_range(-2.0, 2.0),
			randf_range(-2.0, 2.0)
		)
	
	await get_tree().create_timer(4).timeout
	queue_free()
