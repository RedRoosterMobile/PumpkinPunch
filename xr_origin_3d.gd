class_name MyOrigin extends Node3D

signal focus_lost
signal focus_gained
signal pose_recentered

@export var maximum_refresh_rate : int = 90

# needed? if yes forward the signal out of the scene via a new signal, like signal_lost
@export var left_hand_body:RigidBody3D
@export var right_hand_body:RigidBody3D

@onready var left_hand_controller: XRController3D = $LeftHandController
@onready var right_hand_controller: XRController3D = $RightHandController

var xr_interface : OpenXRInterface
var xr_is_focussed = false
# https://github.com/godotengine/godot-demo-projects/blob/4.2/xr/openxr_origin_centric_movement/start_vr.gd

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR instantiated successfully.")
		var vp : Viewport = get_viewport()

		# Enable XR on our viewport
		vp.use_xr = true

		# Make sure v-sync is off, v-sync is handled by OpenXR
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Connect the OpenXR events
		xr_interface.connect("session_begun", _on_openxr_session_begun)
		xr_interface.connect("session_visible", _on_openxr_visible_state)
		xr_interface.connect("session_focussed", _on_openxr_focused_state)
		xr_interface.connect("session_stopping", _on_openxr_stopping)
		xr_interface.connect("pose_recentered", _on_openxr_pose_recentered)
	else:
		# We couldn't start OpenXR.
		print("OpenXR not instantiated!")
		get_tree().quit()

# called from the outside
func init_hands():
	print("if we passed in a left hand body, assign it to lhc")
	print(left_hand_controller)
	#left_hand_controller.add_child(left_hand_body)
	#left_hand_controller.add_child(right_hand_body)
	print("if we passed in a right hand body, assign it to rhc")
	pass

# Handle OpenXR session ready
func _on_openxr_session_begun() -> void:
	# Get the reported refresh rate
	var current_refresh_rate = xr_interface.get_display_refresh_rate()
	if current_refresh_rate > 0:
		print("OpenXR: Refresh rate reported as ", str(current_refresh_rate))
	else:
		print("OpenXR: No refresh rate given by XR runtime")

	# See if we have a better refresh rate available
	var new_rate = current_refresh_rate
	var available_rates : Array = xr_interface.get_available_display_refresh_rates()
	if available_rates.size() == 0:
		print("OpenXR: Target does not support refresh rate extension")
	elif available_rates.size() == 1:
		# Only one available, so use it
		new_rate = available_rates[0]
	else:
		for rate in available_rates:
			if rate > new_rate and rate <= maximum_refresh_rate:
				new_rate = rate

	# Did we find a better rate?
	if current_refresh_rate != new_rate:
		print("OpenXR: Setting refresh rate to ", str(new_rate))
		xr_interface.set_display_refresh_rate(new_rate)
		current_refresh_rate = new_rate

	# Now match our physics rate
	Engine.physics_ticks_per_second = current_refresh_rate


# Handle OpenXR visible state
func _on_openxr_visible_state() -> void:
	# We always pass this state at startup,
	# but the second time we get this it means our player took off their headset
	if xr_is_focussed:
		print("OpenXR lost focus")

		xr_is_focussed = false

		# pause our game
		process_mode = Node.PROCESS_MODE_DISABLED

		emit_signal("focus_lost")


# Handle OpenXR focused state
func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focussed = true

	# unpause our game
	process_mode = Node.PROCESS_MODE_INHERIT

	emit_signal("focus_gained")

# Handle OpenXR stopping state
func _on_openxr_stopping() -> void:
	# Our session is being stopped.
	print("OpenXR is stopping")

# Handle OpenXR pose recentered signal
func _on_openxr_pose_recentered() -> void:
	# User recentered view, we have to react to this by recentering the view.
	# This is game implementation dependent.
	emit_signal("pose_recentered")
