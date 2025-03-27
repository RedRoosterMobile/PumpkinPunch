extends Node3D
@onready var swarm: GPUParticles3D = $GPUParticles3D
@export var attack_duration: float = 5.0
@export var down_angle_deg: float = 23.0
var initial_rotation: Vector3
var ppm: ParticleProcessMaterial
@onready var player_bat_distractor: GPUParticlesAttractorSphere3D = $PlayerBatDistractor

func _ready() -> void:
	initial_rotation=rotation
	Messenger.spawn_bat_swarm.connect(_handle_swarm_spawn)
	swarm.emitting = false
	ppm = swarm.process_material
	ppm.turbulence_enabled = true

func _process(delta:float) -> void:
	if GameState.is_left_hand_blocking_swarm and GameState.is_right_hand_blocking_swarm:
		player_bat_distractor.visible = true
	else:
		player_bat_distractor.visible = false

func _handle_swarm_spawn() -> void:
	ppm.turbulence_enabled = false
	swarm.rotate_x(deg_to_rad(down_angle_deg))
	swarm.emitting = true
	
	await get_tree().create_timer(attack_duration).timeout
	Messenger.stop_bat_swarm.emit()
	#swarm.emitting = false
	ppm.turbulence_enabled = true
	swarm.rotation = initial_rotation
