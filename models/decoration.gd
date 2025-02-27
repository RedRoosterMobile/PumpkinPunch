extends Node3D

@onready var tree_pine_orange_medium_3: Node3D = $tree_pine_orange_medium3
@onready var tree_pine_orange_medium_2: Node3D = $tree_pine_orange_medium2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
var time: float = 0.0
func _physics_process(delta: float) -> void:
	time += delta
	var sinner = sin(time)
	
	tree_pine_orange_medium_3.rotate_x(deg_to_rad(0.025*sinner))
	
	var cosser = sin(time*0.9+5) 
	tree_pine_orange_medium_2.rotate_x(deg_to_rad(0.035*cosser))
