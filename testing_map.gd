extends Node
# assets https://godotengine.org/asset-library/asset/2224
@export var left_hand_body: RigidBody3D 
@export var right_hand_body: RigidBody3D

@export var is_midi_enabled: bool = true

@export var xr_enabled:bool = false
var controller_left : XRController3D
var controller_right : XRController3D
@export var spawn_action : String = "trigger_click"

# Inner class
class Pumpkin:
	var node: Node3D

var pumpkins:Array[Pumpkin]= []
var time:float = 0.0
var start_pos:Vector3

var swarm_block_time:float = 0.0
var is_swarm_active: bool = false

const PUMPKIN_Z:float = -6.0 # back/front
const PUMPKIN_X:float = 1.1 # left/right
const PUMPKIN_Y:float = 1 # up/down

# use this for spawning
#const SPAWN_THING:PackedScene = preload("res://models/pumpkin_hollow_full_modified.tscn")
#const SPAWN_THING_BROKEN:PackedScene = preload("res://models/pumpkin_hollow_pieces_modified.tscn")
#const SPAWN_THING:PackedScene = preload("res://models/lowpoly_pumpkin_full.tscn")
#const SPAWN_THING_BROKEN:PackedScene = preload("res://models/lowpoly_pumpkin_pieces.tscn")
const SPAWN_THING:PackedScene = preload("res://models/lowpoly_pumpkin_full_scaled.tscn")
const SPAWN_THING_BROKEN:PackedScene = preload("res://models/lowpoly_pumpkin_pieces_scaled.tscn")
const XR_INIT:PackedScene = preload("res://xr_origin_3d.tscn")

func _on_game_started():
	if pumpkins.size() > 0:
		# FIXME: do this when the first pumpkin has spawned
		var a_pumpkin: Node3D = pumpkins[0].node
		pumpkin_grin(a_pumpkin.get_material())
	GameState.game_started = true
	time = 0.0
	if is_midi_enabled:
		init_midi()
	else:
		# set demo song 
		var audio_stream = load("res://art/Haunted Beats (1).mp3")  # Load the MP3 file directly
		asp.stream = audio_stream
		asp.play()

func _on_swarm_started() -> void:
	swarm_block_time = 0.0 # just to make sure
	is_swarm_active = true

func _on_swarm_stopped() -> void:
	is_swarm_active = false
	print("###swarm_block_time###")
	print(swarm_block_time)
	# TODO: points! depending on swarm time
	# 5 sec is "currently" optimal -> check "attack_duration" parameter of BatSwarm
	if (swarm_block_time > 3.0):
		print("##you blocked the swarm!")
	swarm_block_time = 0.0

func _ready() -> void:
	Messenger.game_started.connect(_on_game_started)
	Messenger.spawn_bat_swarm.connect(_on_swarm_started)
	Messenger.stop_bat_swarm.connect(_on_swarm_stopped)
	
	print("xr_controls_enabled")
	print(xr_enabled)
	var hand_area_left:Area3D = left_hand_body.get_node("HandArea3D")
	hand_area_left.connect("area_entered",_on_hand_area_3d_area_entered_left)
	
	var hand_area_right:Area3D = right_hand_body.get_node("HandArea3D")
	hand_area_right.connect("area_entered",_on_hand_area_3d_area_entered_right)
	# xr scene will add those to it's tree 
	if xr_enabled:
		var xr_origin_3d: MyOrigin = XR_INIT.instantiate()
		xr_origin_3d.left_hand_body = left_hand_body
		xr_origin_3d.right_hand_body = right_hand_body
		add_child(xr_origin_3d)
		
		xr_origin_3d.init_hands()
		print("left hand controller")
		# left controller
		controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
		if controller_left:
			controller_left.button_pressed.connect(_on_button_pressed_left)
			
		# right controller
		controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
		if controller_right:
			controller_right.button_pressed.connect(_on_button_pressed_right)

func _process(delta: float) -> void:
	time += delta
	
	if GameState.game_started and not GameState.game_finished:
		create_new_pumpkin()
		if is_swarm_active:
			if GameState.is_left_hand_blocking_swarm and GameState.is_right_hand_blocking_swarm:
				swarm_block_time += delta
				$ForceField.visible = true
			else:
				$ForceField.visible = false
		else:
			$ForceField.visible = false
	if not xr_enabled:
		follow_mouse()
	# Remove null entries from the array
	pumpkins = pumpkins.filter(func(pumpkin):
		return pumpkin != null and pumpkin.node != null
	)
	
	for pumpkin:Pumpkin in pumpkins:
		pumpkin.node.position.z += delta 
		# tune kill zone
		if pumpkin.node.position.z > 1:
			# pumpkin went 6 + 1 = 7 meters
			# -6 + 6 + 1
			#pumpkin.node.position.z = PUMPKIN_Z
			Messenger.add_score.emit(GameState.SCORE_MISSED_PUMPKIN)
			pumpkin.node.queue_free()
		
	$DebugLabel3D.text = "blocking swarm hitbox: " + str(GameState.is_left_hand_blocking_swarm and GameState.is_right_hand_blocking_swarm) + "\n" 
	if GameState.is_left_hand_blocking_bat and GameState.is_right_hand_blocking_bat:
		print("stop bat")
		Messenger.is_blocking_bat.emit()
	
	# Variables to track state
var controller_spawn_just_pressed: bool = false
var prev_controller_states: Dictionary = {}  # Stores previous state for each controller

@export var rumble_event_left : XRToolsRumbleEvent
@export var rumble_event_right : XRToolsRumbleEvent
func _on_button_pressed_left(button_name: String) -> void:
	match button_name:
		"ax_button":
			Messenger.spawn_big_bat.emit()
			print("button: spawn bat")
		"by_button":
			print("button: spawn swarm")
			Messenger.spawn_bat_swarm.emit()

func _on_button_pressed_right(button_name: String) -> void:
	match button_name:
		"ax_button":
			print("button: end game")
			Messenger.game_finished.emit()
			GameState.game_finished = true
		"by_button":
			print("right by_button not (yet) implemented")

func create_new_pumpkin():
	var controllers = XRServer.get_trackers(XRServer.TRACKER_CONTROLLER)
	controller_spawn_just_pressed = false  # Reset each frame
	
	if xr_enabled:
		# XRhelper style of getting keys
		# https://github.com/GodotVR/godot-xr-tools/pull/557/files#diff-a9959fdf1a493f41ed711540fffaf024b7561fb8eaf7017987b7b2c2d36317e3
		if controller_left and controller_left.get_is_active() and controller_left.is_button_pressed(spawn_action):
			#print(controller_left.get_tracker_hand())
			#print("pressed")
			pass
		# refactor this to the above??
		for name in controllers:
			var tracker: XRPositionalTracker = controllers[name]
			var current_state = tracker.get_input(spawn_action)
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
	if Input.is_action_just_pressed("spawn") or controller_spawn_just_pressed:
		print("Spawning!")
		# FIXME: get from object pool instead
		var pumpkin = SPAWN_THING.instantiate()
		var pumpkin_pieces = SPAWN_THING_BROKEN
		
		var x_spawn:float
		if randi_range(0,1):
			x_spawn = PUMPKIN_X*-1.0
		else:
			x_spawn = PUMPKIN_X
		var spawn_position:Vector3 = Vector3(x_spawn, PUMPKIN_Y, PUMPKIN_Z)
		pumpkin.position = spawn_position
		pumpkin.broken_model = pumpkin_pieces
		pumpkin.add_to_group("pumpkins")
		add_child(pumpkin)
		var p = Pumpkin.new()
		p.node = pumpkin
		
		pumpkins.append(p)
		Messenger.pumpkin_spawned.emit(spawn_position)

### 0 - 127 
func spawn_bats(track:int, pitch:int, velocity:int):
	if track==2:
		print("big bat")
		Messenger.spawn_big_bat.emit()
	elif track==3:
		print("bat swarm")
		Messenger.spawn_bat_swarm.emit()

func spawn_pumpkin(track:int,pitch:int, velocity:int):
	# FIXME: get from object pool instead
	var pumpkin = SPAWN_THING.instantiate()
	var pumpkin_pieces = SPAWN_THING_BROKEN
	
	var x_spawn:float
	if track==0:
		x_spawn = PUMPKIN_X*-1.0
	elif track==1:
		x_spawn = PUMPKIN_X
	var spawn_position:Vector3 = Vector3(x_spawn, PUMPKIN_Y, PUMPKIN_Z)
	pumpkin.position = spawn_position
	pumpkin.broken_model = pumpkin_pieces
	pumpkin.add_to_group("pumpkins")
	add_child(pumpkin)
	var p = Pumpkin.new()
	p.node = pumpkin
	
	pumpkins.append(p)
	Messenger.pumpkin_spawned.emit(spawn_position)	
	
func pumpkin_grin(stm:StandardMaterial3D) -> void:
	# Create new tween
	var tween: Tween
	tween = create_tween()
	tween.set_loops()  # Makes it repeat forever
	
	var initial_color: Color
	
	# Animation parameters
	var animation_duration: float = 2.0  # Duration for full cycle (to white and back)
	# Animate to white
	tween.tween_property(
		stm, 
		"albedo_color", 
		Color.BLUE, 
		animation_duration / 2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)  # And this
	
	# Animate back to initial color
	tween.tween_property(
		stm, 
		"albedo_color", 
		initial_color, 
		animation_duration / 2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)  # And this

func follow_mouse():
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

func _on_hand_area_3d_area_entered_left(area: Area3D):
	_on_hand_area_3d_area_entered(area, controller_left)
	
func _on_hand_area_3d_area_entered_right(area: Area3D):
	_on_hand_area_3d_area_entered(area, controller_right)

func _on_hand_area_3d_area_entered(area: Area3D, controller: XRController3D) -> void:
	# The area is the pumpkin's Area3D. We need to find the HandArea3D that detected it.
	# Use the physics collision data or node hierarchy to trace back to HandArea3D
	var colliding_area = area  # The pumpkin's Area3D
	var is_pumpkin:bool = area.get_parent().is_in_group("pumpkins")
	if is_pumpkin:
		area.get_parent().splat()
		Messenger.add_score.emit(GameState.SCORE_PUNCHED_PUMPKIN)
		if xr_enabled:
			XRToolsRumbleManager.add(controller.name + "left", rumble_event_left, [controller])

# with music:
# - spawn them on midi notes
# - TBD
@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var asp: AudioStreamPlayer = $MainMusicAudioStreamPlayer
func init_midi():
	# midi_player.loop = true
	midi_player.note.connect(note_callback)
	midi_player.speed_scale=1.025
	

	 # link the AudioStreamPlayer in your scene
	# that contains the music associated with the midi
	# NOTE: this must be an array, you can link multiple ASPs or one as 
	# shown below and they will all sync with playback of the MIDI
	# midi_player.link_audio_stream_player([asp])

	# this will also start the audio stream player (music)
	midi_player.play()
	asp.play()

@onready var grave_left: Node3D = $decoration/grave_A2
@onready var grave_right: Node3D = $decoration/grave_A_destroyed3

func note_callback(event: Variant, track: int):
	if event['subtype'] == MIDI_MESSAGE_NOTE_ON:
		#print(event)
		# { "type": "note", "track": 1, "subtype": 9, "delta": 1536.0, "note": 36, "data": 100, "channel": 0 }

		# 36 == C1 (only in ableton??? 24 otherwise)
		var pitch: int = event['note']
		var velocity: int = event['data']
		
		if track == 0 or track == 1:
			spawn_pumpkin(track, pitch, velocity)
		if track == 2 or track == 3:
			spawn_bats(track, pitch, velocity)
