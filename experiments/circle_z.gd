extends MeshInstance3D

@export var radius: float = 2.0          # Size of the circular path
@export var speed: float = 10.0           # Speed of orbit (radians per second)
@export var rotate_clockwise: bool = true # Direction of orbit

var angle: float = 0.0                   # Current angle in radians

func _ready():
	# No input handling needed for constant orbiting
	pass

func _process(delta):
	# Update the angle based on speed and direction
	var direction = -1.0 if rotate_clockwise else 1.0
	angle += speed * direction * delta
	
	# Calculate new X and Y positions using sine and cosine
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	
	# Set the position (keeping original z)
	position = Vector3(x, y, position.z)
