extends Node3D

@export var INTENSITY:float = 8.0
var shot_direction: Vector3   # This should be set to the direction from which the pumpkin was shot
# ideas:
# make the explosion stronger on a certain side
# add some randomness

func _ready() -> void:
	for piece:RigidBody3D in self.get_children():
		piece.apply_impulse(piece.get_child(0).position.normalized() * INTENSITY*randf_range(0.8,1.2), self.global_position)
		#await get_tree().create_timer(randf_range(3,4.5)).timeout
		#piece.queue_free()
	await get_tree().create_timer(5).timeout
	queue_free()

func _ready_dir() -> void:
	# pass this in from the outside
	shot_direction = Vector3.BACK
	# Ensure the shot_direction is normalized
	shot_direction = shot_direction.normalized()

	for piece: RigidBody3D in get_children():
		# Calculate the vector from the explosion center to the piece
		var direction_to_piece = (piece.global_transform.origin - global_transform.origin).normalized()
		
		# Compute the dot product between the piece direction and the negative shot direction
		var cos_theta = direction_to_piece.dot(-shot_direction)
		
		# Adjust the intensity factor (mapping from [-1, 1] to [0, 1])
		var intensity_factor = (cos_theta + 1) / 2
		intensity_factor*=2
		
		# Calculate the impulse
		var impulse = direction_to_piece * INTENSITY * intensity_factor
		
		# Apply the impulse at the piece's position
		piece.apply_impulse(impulse, piece.global_transform.origin)
	
	# Optional: Wait before freeing the node
	await get_tree().create_timer(5).timeout
	queue_free()
