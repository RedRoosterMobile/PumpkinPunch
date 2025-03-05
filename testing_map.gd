extends Node
# assets https://godotengine.org/asset-library/asset/2224
@export var left_hand_body: RigidBody3D 
@export var right_hand_body: RigidBody3D

@export var xr_enabled:bool = false
var controller_left : XRController3D
var controller_right : XRController3D
@export var spawn_action : String = "trigger_click"

# Inner class
class Pumpkin:
	var node: Node3D
	var start_position: Vector3

var pumpkins:Array[Pumpkin]= []
var time:float = 0.0
var start_pos:Vector3

const PUMPKIN_Z:float = -6.0 # back/front
const PUMPKIN_X:float = 1.1 # left/right
const PUMPKIN_Y:float = 1 # up/down

# use this for spawning
#const SPAWN_THING:PackedScene = preload("res://models/pumpkin_hollow_full_modified.tscn")
#const SPAWN_THING_BROKEN:PackedScene = preload("res://models/pumpkin_hollow_pieces_modified.tscn")
const SPAWN_THING:PackedScene = preload("res://models/lowpoly_pumpkin_full.tscn")
const SPAWN_THING_BROKEN:PackedScene = preload("res://models/lowpoly_pumpkin_pieces.tscn")
const XR_INIT:PackedScene = preload("res://xr_origin_3d.tscn")
# use this for initial positions
var pumpkin_start_positions: Array[Vector3] = [
	Vector3(-1.26961, 1.08145, -2.11638),
	Vector3(0.960844, 1.08145, -2.11638),
	Vector3(-0.062555, 0.91448, -0.284467),
	Vector3(-1.18586, 1.08145, -5.71892),
	Vector3(1.11298, 1.08145, -5.71892)
]
func _ready() -> void:
	
	for thing:Node in get_children():
		if thing.is_in_group("pumpkins"):
			var p = Pumpkin.new()
			p.node = thing
			p.start_position = thing.position
			# pumpkin_start_positions.append(thing.position)
			pumpkins.append(p)
			thing.scale *= 0.5
			start_pos = thing.position
			
	print(pumpkin_start_positions)
	
	print("xr_controls_enabled")
	print(xr_enabled)
	var hand_area_left:Area3D = left_hand_body.get_node("HandArea3D")
	hand_area_left.connect("area_entered",_on_hand_area_3d_area_entered)
	
	var hand_area_right:Area3D = right_hand_body.get_node("HandArea3D")
	hand_area_right.connect("area_entered",_on_hand_area_3d_area_entered)
	# xr scene will add those to it's tree 
	if xr_enabled:
		var xr_origin_3d: MyOrigin = XR_INIT.instantiate()
		xr_origin_3d.left_hand_body = left_hand_body
		xr_origin_3d.right_hand_body = right_hand_body
		add_child(xr_origin_3d)
		
		xr_origin_3d.init_hands()
		#await get_tree().create_timer(2).timeout
		print("left hand controller")
		# left controller
		controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
		if controller_left:
			controller_left.button_pressed.connect(_on_button_pressed)
			
		# right controller
		controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
		if controller_right:
			controller_right.button_pressed.connect(_on_button_pressed)
		

#func _physics_process(delta: float) -> void:
func _process(delta: float) -> void:
	time += delta
	
	create_new_pumpkin()
	if not xr_enabled:
		follow_mouse()
	# Remove null entries from the array
	pumpkins = pumpkins.filter(func(pumpkin):
		return pumpkin != null and pumpkin.node != null
	)

	var sinner = sin(time)
	for pumpkin:Pumpkin in pumpkins:
		pumpkin.node.position.z += delta 
		#pumpkin.node.position.x = pumpkin.start_position.x + sinner 
		pumpkin.node.position.y += sinner/300 
		
		if pumpkin.node.position.z > 3:
			pumpkin.node.position.z = PUMPKIN_Z
	$Label3D.text = str(Engine.get_frames_per_second())
	
	# Variables to track state
var controller_spawn_just_pressed: bool = false
var prev_controller_states: Dictionary = {}  # Stores previous state for each controller

## Rumble event for pushing A or X
@export var ax_button_event : XRToolsRumbleEvent

## Rumble event for pushing B or Y
@export var by_button_event : XRToolsRumbleEvent
func _on_button_pressed(button_name: String) -> void:
	#print("rumble")
	return
	match button_name:
		# works!
		"ax_button":
			XRToolsRumbleManager.add(controller_left.name + "ax", ax_button_event, [controller_left])
		"by_button":
			XRToolsRumbleManager.add(controller_left.name + "by", by_button_event, [controller_left])

func create_new_pumpkin():
	var controllers = XRServer.get_trackers(XRServer.TRACKER_CONTROLLER)
	controller_spawn_just_pressed = false  # Reset each frame
	
	if xr_enabled:
		# XRhelper style of getting keys
		# https://github.com/GodotVR/godot-xr-tools/pull/557/files#diff-a9959fdf1a493f41ed711540fffaf024b7561fb8eaf7017987b7b2c2d36317e3
		if controller_left and controller_left.get_is_active() and controller_left.is_button_pressed(spawn_action):
			print(controller_left.get_tracker_hand())
			#print("pressed")
		# refactor this to the above??
		for name in controllers:
			var tracker: XRPositionalTracker = controllers[name]
			var current_state = tracker.get_input(spawn_action)
			# print(name) # "left_hand" "right_hand"
			#
			# XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT
			# XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT
			# print(tracker.hand) # int

			# Initialize previous state if not set
			if not prev_controller_states.has(name):
				prev_controller_states[name] = false
			
			# Check if trigger was just pressed
			if current_state and not prev_controller_states[name]:
				controller_spawn_just_pressed = true
			
			# Update previous state
			prev_controller_states[name] = current_state
	
	# Trigger spawn only when just pressed
	if Input.is_action_just_pressed("spawn") or pumpkins.size() <= 0 or controller_spawn_just_pressed:
		print("Spawning!")
		var pumpkin = SPAWN_THING.instantiate()
		var pumpkin_pieces = SPAWN_THING_BROKEN
		pumpkin.scale *= 0.5
		# pumpkin.look_at_from_position()
		#pumpkin.look_at(left_hand_body.global_position)
		# pumpkin.rotate_y(30) # do some deg2rad things
		pumpkin.position = pumpkin_start_positions[4]
		pumpkin.broken_model = pumpkin_pieces
		pumpkin.add_to_group("pumpkins")
		add_child(pumpkin)
		var p = Pumpkin.new()
		p.node = pumpkin
		p.start_position = pumpkin.position
		pumpkins.append(p)
	pass
	

func follow_mouse():
	# todo: only if not XR
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return  # Ensure the camera exists
	# Get the mouse position in the viewport
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Project a ray from the camera through the mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var intersection_point = ray_origin + ray_direction
	if left_hand_body:
		left_hand_body.position = intersection_point

func _on_hand_area_3d_area_entered(area: Area3D) -> void:
	print("ball hit---")
	print(area)
	print(area.get_parent())
	print(self)  # testing_map
	print("ball END---")
	
	# The area is the pumpkin's Area3D. We need to find the HandArea3D that detected it.
	# Use the physics collision data or node hierarchy to trace back to HandArea3D
	var colliding_area = area  # The pumpkin's Area3D
	var is_pumpkin:bool = area.get_parent().is_in_group("pumpkins")
	if is_pumpkin:
		area.get_parent().splat()
		
	if xr_enabled and is_pumpkin:
		# Since we can't directly get HandArea3D from the pumpkin, we need to search for the HandArea3D
		# that intersects with this area. This requires checking all HandArea3D nodes in the scene.
		var hand_areas = get_tree().get_nodes_in_group("hand_areas")  # Assume HandArea3D nodes are in a "hand_areas" group
		
		for hand_area in hand_areas:
			if hand_area is Area3D and hand_area.overlaps_area(colliding_area):
				# Found the HandArea3D that detected the collision
				print("Found HandArea3D: ", hand_area.name)
				
				# Check its parent to determine the hand
				var hand_parent = hand_area.get_parent()
				
				if hand_parent and hand_parent.name == "HandLeft":
					print("Left hand triggered the event")
					# Handle left hand-specific logic here
					XRToolsRumbleManager.add(controller_left.name + "by", by_button_event, [controller_left])
				elif hand_parent and hand_parent.name == "HandRight":
					print("Right hand triggered the event")
					# Handle right hand-specific logic here
					XRToolsRumbleManager.add(controller_right.name + "by", by_button_event, [controller_right])
				else:
					print("Unknown hand triggered the event. HandArea3D parent: ", hand_parent.name if hand_parent else "No parent")
				break  # Exit the loop once we find the matching HandArea3D
	
	
# dynamically load pumpkins:
# on ready:
# - spawn pumpkins with position
# - add to array of custom class
# process:
# - filter destroyed pumpkins
# - add more if below limit
# - move them forward or reset if behind threshold
# physica handler of glove:
# - delete touched pumpkin
# - delete reference from array

# with music:
# - spawn them on midi notes
# - TBD
