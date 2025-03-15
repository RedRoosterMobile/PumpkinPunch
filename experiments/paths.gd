extends Node3D

@onready var path_3d: Path3D = $Path3D
@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D

var speed: float = 2.0
var is_moving: bool = false

func _ready():
	set_process_input(true)

func _process(delta):
	if is_moving:
		path_follow.progress += speed * delta
		# Stop at end instead of looping
		if path_follow.progress_ratio >= 1.0:
			is_moving = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			if !is_moving:
				print("Starting path animation")
				path_follow.progress = 0.0  # Reset to start
				is_moving = true
			else:
				print("Stopping path animation")
				is_moving = false
			
		if event.keycode == KEY_R:  # Reset position
			print("Resetting to start")
			path_follow.progress = 0.0
			is_moving = false
			
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click - Speed up")
			speed += 1.0
		if event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right click - Slow down")
			speed = max(0.5, speed - 1.0)  # Prevent going too slow
