extends Node3D

@onready var tree_pine_orange_medium_3: Node3D = $tree_pine_orange_medium3
@onready var tree_pine_orange_medium_2: Node3D = $tree_pine_orange_medium2
@onready var tree_pine_orange_medium_4: Node3D = $tree_pine_orange_medium4
@onready var tree_pine_orange_medium_5: Node3D = $tree_pine_orange_medium5
@onready var small_tree: Node3D = $tree_pine_yellow_medium3

# "treeshake" animation
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	var sinner:float = sin(time)
	
	tree_pine_orange_medium_3.rotate_x(deg_to_rad(0.025*sinner))
	tree_pine_orange_medium_5.rotate_x(deg_to_rad(0.038*sinner))
	
	var cosser:float = sin(time*0.9+5) 
	tree_pine_orange_medium_2.rotate_x(deg_to_rad(0.035*cosser))
	tree_pine_orange_medium_4.rotate_x(deg_to_rad(0.025*cosser))
	
	small_tree.rotate_x(deg_to_rad(0.018*sinner))
