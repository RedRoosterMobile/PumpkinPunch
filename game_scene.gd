extends XRToolsSceneBase
# assets https://godotengine.org/asset-library/asset/2224
@export var left_hand_body: RigidBody3D
@export var right_hand_body: RigidBody3D
@onready var mana: Node3D = $HealthMeter/mana
const mana_change_amount: float = 0.1
var track1_spawn_count: int = 0 # Counts track 1 spawns

var controller_left: XRController3D
var controller_right: XRController3D
@export var spawn_action: String = "trigger_click"
@export var spawn_big_bat_action: String = "ax_button"
@export var spawn_swarm_action: String = "by_button"
@export var end_game_action: String = "ax_button"
@export var next_scene_action: String = "by_button"



@onready var ap: AnimationPlayer = $GameStateLabel/AnimationPlayer
	

# Inner class
class Pumpkin:
	var node: Node3D
	var type: String
	var spiral_time: float = 0.0 # Only used for spiral pumpkins
	var movement_radius: float
	var movement_frequency: float
	var velocity_multiplier: float

	func _init(_type: String):
		type = _type
		movement_radius = randf_range(0.3, 0.7)
		movement_frequency = randf_range(1.5, 2.5)

var pumpkins: Array[Pumpkin] = []
var time: float = 0.0
var start_pos: Vector3

var swarm_block_time: float = 0.0
var is_swarm_active: bool = false

const PUMPKIN_Z: float = -6.0 # back/front
const PUMPKIN_X: float = 1.1 # left/right
const PUMPKIN_Y: float = 1 # up/down

# use this for spawning
#const SPAWN_THING:PackedScene = preload("res://models/pumpkin_hollow_full_modified.tscn")
#const SPAWN_THING_BROKEN:PackedScene = preload("res://models/pumpkin_hollow_pieces_modified.tscn")
#const SPAWN_THING:PackedScene = preload("res://models/lowpoly_pumpkin_full.tscn")
#const SPAWN_THING_BROKEN:PackedScene = preload("res://models/lowpoly_pumpkin_pieces.tscn")
const SPAWN_THING: PackedScene = preload("res://models/lowpoly_pumpkin_full_scaled.tscn")
const SPAWN_THING_BROKEN: PackedScene = preload("res://models/lowpoly_pumpkin_pieces_scaled.tscn")
const XR_ORIGIN: PackedScene = preload("res://xr_origin_3d.tscn")

func _on_game_started():
	#start_game()
	pass
	
func start_game():
	if pumpkins.size() > 0:
		# FIXME: do this when the first pumpkin has spawned
		var a_pumpkin: Node3D = pumpkins[0].node
		pumpkin_grin(a_pumpkin.get_material())
	GameState.game_started = true
	time = 0.0
	init_midi()

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
		add_mana(mana_change_amount)
	else:
		print("##eaten by the swarm!")
		lose_mana(mana_change_amount)
	swarm_block_time = 0.0

func _ready() -> void:
	Messenger.game_started.connect(_on_game_started)
	Messenger.spawn_bat_swarm.connect(_on_swarm_started)
	Messenger.stop_bat_swarm.connect(_on_swarm_stopped)
	show_game_state_label(false)
	
	print("xr_controls_enabled")
	var hand_area_left: Area3D = left_hand_body.get_node("HandArea3D")
	hand_area_left.connect("area_entered", _on_hand_area_3d_area_entered_left)
	
	var hand_area_right: Area3D = right_hand_body.get_node("HandArea3D")
	hand_area_right.connect("area_entered", _on_hand_area_3d_area_entered_right)
	# xr scene will add those to it's tree 
	
	var xr_origin_3d: MyOrigin = XR_ORIGIN.instantiate()
	add_child(xr_origin_3d)
		
	xr_origin_3d.init_hands(left_hand_body, right_hand_body)
	# left controller
	controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
	if controller_left:
		controller_left.button_pressed.connect(_on_button_pressed_left)
	
	# right controller
	controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
	if controller_right:
		controller_right.button_pressed.connect(_on_button_pressed_right)
	
	start_game()

func _process(delta: float) -> void:
	time += delta
	
	var is_game_running: bool = GameState.game_started and not GameState.game_finished
	var is_blocking_swarm: bool = GameState.is_left_hand_blocking_swarm and GameState.is_right_hand_blocking_swarm
	var is_blocking_bat: bool = GameState.is_left_hand_blocking_bat and GameState.is_right_hand_blocking_bat
	
	if is_game_running:
		if is_swarm_active:
			if is_blocking_swarm:
				swarm_block_time += delta
				$ForceFieldNew.visible = true
			else:
				$ForceFieldNew.visible = false
		else:
			$ForceFieldNew.visible = false
	
	#region Remove null pumpkins from the array
	pumpkins = pumpkins.filter(func(pumpkin):
		return pumpkin != null and pumpkin.node != null
	)
	
	#region pumpkin kill-zone
	for pumpkin:Pumpkin in pumpkins:
		pumpkin.node.position.z += delta * pumpkin.velocity_multiplier
		# var time_zto = sin(time*0.5)*0.5+0.5
		# pumpkin.node.position.y = PUMPKIN_Y * time_zto*1.0
		# tune kill zone
		pumpkin.spiral_time += delta

		if pumpkin.type == 'wobble':
			pumpkin.node.position.x = sin(pumpkin.spiral_time * pumpkin.movement_frequency) * pumpkin.movement_radius
			pumpkin.node.position.y = pumpkin.node.position.y # No change, or set to spawn Y + 1
		if pumpkin.type == 'spiral':
			pumpkin.node.position.x = cos(pumpkin.spiral_time * pumpkin.movement_frequency) * pumpkin.movement_radius
			pumpkin.node.position.y = sin(pumpkin.spiral_time * pumpkin.movement_frequency) * pumpkin.movement_radius + 1
		
		if pumpkin.node.position.z > 0.5:
			# pumpkin went 6 + 0.5 = 6.5 meters
			# -6 + 6 + 0.5
			lose_mana(mana_change_amount)
			mana.scale.y -= mana_change_amount
			pumpkin.node.queue_free()
	
	#region blocking the swarm
	# debug
	$DebugLabel3D.text = "blocking swarm hitbox: " + str(is_blocking_swarm) + "\n" 
	
	if is_blocking_bat:
		Messenger.is_blocking_bat.emit()
	mana.scale.y = GameState.mana_fill_level

func lose_mana(amount: float):
	GameState.mana_fill_level -= amount
	if GameState.mana_fill_level <= 0.0:
		Messenger.game_finished.emit()
		GameState.game_finished = true
		Messenger.skeleton_won.emit()
		show_game_state_label(true)
	GameState.mana_fill_level = clampf(GameState.mana_fill_level, 0.0, 1.0)

func add_mana(amount: float):
	GameState.mana_fill_level += amount
	GameState.mana_fill_level = clampf(GameState.mana_fill_level, 0.0, 1.0)

@export var rumble_event_left: XRToolsRumbleEvent
@export var rumble_event_right: XRToolsRumbleEvent

func _on_button_pressed_left(button_name: String) -> void:
	match button_name:
		spawn_big_bat_action:
			Messenger.spawn_big_bat.emit()
			print("button: spawn bat")
		spawn_swarm_action:
			print("button: spawn swarm")
			Messenger.spawn_bat_swarm.emit()
		spawn_action:
			print("button: spawn a pumpkin")
			#spawn_pumpkin(0, 50, 120)
			show_game_state_label(true, "test")

func _on_button_pressed_right(button_name: String) -> void:
	print(button_name)
	match button_name:
		end_game_action:
			print("button: end game")
			Messenger.game_finished.emit() # kill
			GameState.game_finished = true
		next_scene_action:
			# go to credits
			print("go to credits scene")
			go_to_credits_scene()

### 0 - 127 
func spawn_bats(track: int, pitch: int, velocity: int):
	if track == 2:
		print("big bat")
		Messenger.spawn_big_bat.emit()
	elif track == 3:
		print("bat swarm")
		Messenger.spawn_bat_swarm.emit()

func spawn_pumpkin(track: int, pitch: int, velocity: int):
	# FIXME: get from object pool instead
	print("pitch: ",pitch)
	# C1 = 36
	# C#1 = 37
	var pumpkin = SPAWN_THING.instantiate()
	var pumpkin_pieces = SPAWN_THING_BROKEN

	var x_spawn: float
	var pumpkin_type = ''

	if track == 0:
		x_spawn = PUMPKIN_X * -1.0
	elif track == 1:
		x_spawn = PUMPKIN_X
		track1_spawn_count += 1
		if track1_spawn_count % 2 == 0:
			pumpkin_type = 'spiral'
		if track1_spawn_count % 3 == 0:
			pumpkin_type = 'wobble'

	var spawn_height: float = randf_range(PUMPKIN_Y * 0.5, PUMPKIN_Y * 1.5)
	var spawn_position: Vector3 = Vector3(x_spawn, spawn_height, PUMPKIN_Z)
	pumpkin.position = spawn_position
	pumpkin.broken_model = pumpkin_pieces
	
	pumpkin.add_to_group("pumpkins")
	add_child(pumpkin)
	var p = Pumpkin.new(pumpkin_type)
	
	if (velocity >100):
		p.velocity_multiplier = 1.5
	else: 
		p.velocity_multiplier = 1.0
	p.node = pumpkin
	
	pumpkins.append(p)
	Messenger.pumpkin_spawned.emit(spawn_position)

# unused
func pumpkin_grin(stm: StandardMaterial3D) -> void:
	# Create new tween
	var tween: Tween
	tween = create_tween()
	tween.set_loops() # Makes it repeat forever
	
	var initial_color: Color
	
	# Animation parameters
	var animation_duration: float = 2.0 # Duration for full cycle (to white and back)
	# Animate to white
	tween.tween_property(
		stm,
		"albedo_color",
		Color.BLUE,
		animation_duration / 2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN) # And this
	
	# Animate back to initial color
	tween.tween_property(
		stm,
		"albedo_color",
		initial_color,
		animation_duration / 2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT) # And this

func follow_mouse():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return # Ensure the camera exists
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
	var colliding_area = area # The pumpkin's Area3D
	var is_pumpkin: bool = area.get_parent().is_in_group("pumpkins")
	if is_pumpkin:
		area.get_parent().splat()
		Messenger.add_score.emit(GameState.SCORE_PUNCHED_PUMPKIN)
		add_mana(mana_change_amount)
		XRToolsRumbleManager.add(controller.name + "left", rumble_event_left, [controller])

# with music:
# - spawn them on midi notes
# - TBD
@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var asp: AudioStreamPlayer = $MainMusicAudioStreamPlayer
func init_midi():
	# midi_player.loop = true
	midi_player.note.connect(note_callback)
	# working for demo song
	#midi_player.speed_scale = 1.025
	
	# caluclate this via bpm
	midi_player.speed_scale = 1.15
	
	
	#midi_player.speed_scale = 3.0
	
	#123 120
	
	#138
	#120
	
	 # link the AudioStreamPlayer in your scene
	# that contains the music associated with the midi
	# NOTE: this must be an array, you can link multiple ASPs or one as 
	# shown below and they will all sync with playback of the MIDI
	# this will also start the audio stream player (music)
	#midi_player.link_audio_stream_player([asp])
	
	midi_player.play()
	asp.play()
	asp.connect("finished", _on_music_ended)

func _on_music_ended():
	print("Music ended")
	if not GameState.game_finished:
		GameState.game_finished = true
		Messenger.game_finished.emit() # kill mage
		show_game_state_label(true, "Winner, Winner, Chicken Dinner! \nscore: " + str(GameState.score))

var first_note:Dictionary[int,bool] = {}
func note_callback(event: Variant, track: int):
	if event['subtype'] == MIDI_MESSAGE_NOTE_ON and not GameState.game_finished:
		
		
		# { "type": "note", "track": 1, "subtype": 9, "delta": 1536.0, "note": 36, "data": 100, "channel": 0 }
		# 36 == C1 (only in ableton??? 24 otherwise)
		var pitch: int = event['note']
		var velocity: int = event['data']
				
		if track == 0 or track == 1:
			spawn_pumpkin(track, pitch, velocity)
		if track == 2 or track == 3:
			spawn_bats(track, pitch, velocity)
			
			
func show_game_state_label(show: bool, msg: String = ""):
	print("show_game_state_label")
	$GameStateLabel.visible = show
	if msg.length() > 0:
		$GameStateLabel.text = msg
	if show:
		ap.play("end_game_fly_in")
		await get_tree().create_timer(4).timeout
		go_to_credits_scene()

func go_to_credits_scene():
	print("go_to_credits_scene")
	# Find the XRToolsSceneBase ancestor of the current node
	var scene_base: XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		return
	# Request loading the next scene
	scene_base.load_scene("res://game_scenes/credits_scene.tscn")
