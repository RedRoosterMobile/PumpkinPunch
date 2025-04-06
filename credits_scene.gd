@tool
extends XRToolsSceneBase

# TODO: add some stuff, 
# like switching trails on and off via button press
@onready var xr_origin_3d: XROrigin3D = $XROrigin3D
@onready var left_gpu_trail_3d: GPUTrail3D = $XROrigin3D/LeftHand/LeftGPUTrail3D
@onready var right_gpu_trail_3d: GPUTrail3D = $XROrigin3D/RightHand/RightGPUTrail3D

@export var rumble_event_left : XRToolsRumbleEvent
@export var rumble_event_right : XRToolsRumbleEvent


var controller_left : XRController3D
var controller_right : XRController3D
# rain https://www.youtube.com/watch?v=cZ5Ang_Ji8E&t=4261s
func _ready() -> void:
	controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
	if controller_left:
		controller_left.button_pressed.connect(_on_button_pressed_left)
			
	controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
	if controller_right:
		controller_right.button_pressed.connect(_on_button_pressed_right)


func _on_button_pressed_left(button_name: String) -> void:
	# check: openXR action map at the bottom e.g. "trigger_click", "grip_click"
	match button_name:
		"ax_button":
			print("credits: x pressed")
		"by_button":
			print("credits: y pressed")

func _on_button_pressed_right(button_name: String) -> void:
	match button_name:
		"ax_button":
			print("credits: a pressed")
		"by_button":
			print("credits: b pressed, replay game")
			# Find the XRToolsSceneBase ancestor of the current node
			var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if not scene_base:
				return
			# Request loading the next scene
			scene_base.load_scene("res://game_scenes/game_scene.tscn")
