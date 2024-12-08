extends Node3D

var start_position:Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time:float = 0.0
func _process(delta: float) -> void:
	time += delta
	var sinner:float = sin(time)
	var cosser:float = cos(time)
	position.x =  start_position.x + sinner * 1.0
	position.y =  start_position.y + cosser * 0.5

	
