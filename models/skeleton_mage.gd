# This script controls a 3D node that spawns with an animation, waits for a set delay,
# then switches to an idle animation and oscillates its position horizontally.

extends Node3D

# Reference to the AnimationTree node, initialized when the node is ready
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

# Stores the initial position of the node
var start_position: Vector3

# Timer used for both spawn delay and oscillation
var time: float = 0.0

var has_spawned: bool = false

# Constants for blend positions in the AnimationTree
const BLEND_POSITION_SPAWN: Vector2 = Vector2(0, 1)
const BLEND_POSITION_IDLE: Vector2 = Vector2(-1, 0)
const BLEND_POSITION_DIE: Vector2 = Vector2(0, -1)
const BLEND_POSITION_SHOOT: Vector2 = Vector2(1, 0)

const SPAWN_DELAY: float = 1.3
const OSCILLATION_AMPLITUDE: float = 1.0

func _ready() -> void:
	# Capture the node's starting position
	start_position = position
	# Set the initial animation to the spawn animation
	animation_tree["parameters/blend_position"] = BLEND_POSITION_SPAWN

func _process(delta: float) -> void:
	time += delta

	# Check if the spawn delay has elapsed and the spawn sequence hasn't completed
	if not has_spawned and time > SPAWN_DELAY:
		has_spawned = true
		time = 0.0  # Reset the timer to start oscillation from zero
		animation_tree["parameters/blend_position"] = BLEND_POSITION_IDLE
		gpu_particles_3d.emitting = true

	if has_spawned:
		var offset: float = sin(time*3) * OSCILLATION_AMPLITUDE
		position.x = start_position.x + offset
