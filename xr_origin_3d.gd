class_name MyOrigin extends Node3D

#signal focus_lost
#signal focus_gained
#signal pose_recentered

# 90 jitters sometimes, better keep it low and steady
# @export var maximum_refresh_rate : int = 72

# needed? if yes forward the signal out of the scene via a new signal, like signal_lost
var left_hand_body:RigidBody3D
var right_hand_body:RigidBody3D

@onready var left_hand_controller: XRController3D = $LeftHandController
@onready var right_hand_controller: XRController3D = $RightHandController

# Called when the node enters the scene tree for the first time.
func _ready():
	#xr_interface = XRServer.find_interface("OpenXR")
	# xr_interface.render_target_size_multiplier = 0.8  # 80% of 1680x1760
	# 0.8 = (1344.0, 1408.0)
	#print(xr_interface.get_render_target_size())
	# let start xr handle that stuff
	return

#region my stuff

func _on_player_area_3d_area_entered(area: Area3D) -> void:
	print("sth collided with player")
	Messenger.player_hit.emit(area)

func init_hands(_left_hand_body:RigidBody3D, _right_hand_body:RigidBody3D):
	left_hand_body = _left_hand_body
	right_hand_body = _right_hand_body
	# clean up old hand content
	left_hand_controller.get_child(0).queue_free()
	right_hand_controller.get_child(0).queue_free()
	
	left_hand_body.reparent(left_hand_controller)
	right_hand_body.reparent(right_hand_controller)
#
func update_hands():
	# damn!
	# https://forum.godotengine.org/t/rigid-bodies-as-hands/67646
	if left_hand_body and right_hand_body:
		left_hand_body.global_transform = left_hand_controller.global_transform
		right_hand_body.global_transform = right_hand_controller.global_transform

func _physics_process(delta: float) -> void:
	update_hands()
