# This script controls a 3D node that spawns with an animation, waits for a set delay,
# then switches to an idle animation and oscillates its position horizontally.

extends Node3D

# Reference to the AnimationTree node, initialized when the node is ready
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

# Stores the initial position of the node
var start_position: Vector3
var initial_rotation: Quaternion

# Timer used for both spawn delay and oscillation
var time: float = 0.0

var has_spawned: bool = false
# aka: is not pausing 
var is_moving: bool = true

# Constants for blend positions in the AnimationTree
const BLEND_POSITION_SPAWN: Vector2 = Vector2(0, 1)
const BLEND_POSITION_IDLE: Vector2 = Vector2(-1, 0)
const BLEND_POSITION_DIE: Vector2 = Vector2(0, -1)
const BLEND_POSITION_SHOOT: Vector2 = Vector2(1, 0)

const PARAM_BLEND_POSITION:String = "parameters/blend_position"

const SPAWN_DELAY: float = 2.7
const OSCILLATION_AMPLITUDE: float = 1.0

func _ready() -> void:
	# Capture the node's starting position
	start_position = position
	initial_rotation = quaternion
	# Set the initial animation to the spawn animation
	animation_tree[PARAM_BLEND_POSITION] = BLEND_POSITION_SPAWN
	
	Messenger.game_finished.connect(kill)
	Messenger.pumpkin_spawned.connect(shoot)

func _process(delta: float) -> void:
	if is_moving:
		time += delta

	# Check if the spawn delay has elapsed and the spawn sequence hasn't completed
	if not has_spawned and time > SPAWN_DELAY:
		has_spawned = true
		time = 0.0  # Reset the timer to start oscillation from zero
		animation_tree[PARAM_BLEND_POSITION] = BLEND_POSITION_IDLE
		Messenger.game_started.emit()
		gpu_particles_3d.emitting = true
		# do we need that??
		# GameState.skeleton_resurrected = true
	elif has_spawned:
		var offset: float = sin(time*3) * OSCILLATION_AMPLITUDE
		position.x = start_position.x + offset

func kill():
	is_moving = false
	animation_tree[PARAM_BLEND_POSITION] = BLEND_POSITION_DIE
	Messenger.skeleton_died.emit()

func shoot(pumpkin_pos: Vector3):
	is_moving = false
	animation_tree[PARAM_BLEND_POSITION] = BLEND_POSITION_SHOOT
	
	# Instantly rotate to face the pumpkin
	look_at(pumpkin_pos, Vector3.UP)
	rotate_y(deg_to_rad(180))
	
	print("##### shoot #####")
	var animation_time:float = 1.066
	
	
	await get_tree().create_timer(animation_time).timeout  # Wait for shoot animation
	
	# here we want to actually spawn the pumpkin (callback, signal?)
	
	# Tween back to initial rotation
	var tween = create_tween()
	tween.tween_property(self, "quaternion", initial_rotation, animation_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	animation_tree[PARAM_BLEND_POSITION] = BLEND_POSITION_IDLE
	print("##### back #####")
	# await tween.finished  # Wait for the tween to finish
	is_moving = true
	
# plan: spawn a pumpkin
# - move the mage to the position(or rotate)
# - spawn pumpkin at this postion when shoot animation is done
# - make back to idle immediately
# - rotate mage back
