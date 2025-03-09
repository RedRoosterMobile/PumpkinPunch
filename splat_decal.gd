extends Decal

@export var time: float = 4.0
@export var rotation_range: float = 360.0
@export var scale_min: float = 0.8
@export var scale_max: float = 1.2

func _ready() -> void:
	# Randomize rotation
	var random_rotation = randf_range(-rotation_range/2, rotation_range/2)
	rotate_y(deg_to_rad(random_rotation))
	
	# Randomize scale
	var random_scale = randf_range(scale_min, scale_max)
	scale = Vector3(random_scale, random_scale, random_scale)
