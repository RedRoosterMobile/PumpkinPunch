extends Node3D

@export var broken_model: PackedScene
@export var vfx: PackedScene = preload("res://vfx_hit.tscn")
@export var splat_decal: PackedScene
@onready var pumpkin_orange_jackolantern: MeshInstance3D = $pumpkin_orange_jackolantern

var vfx_instance
var splat_decal_instance

# Animation parameters
@export var animation_duration: float = 2.0  # Duration for full cycle (to white and back)

func _ready() -> void:
	vfx_instance = vfx.instantiate()
	splat_decal_instance = splat_decal.instantiate()

func get_material() -> StandardMaterial3D:
	var stm: StandardMaterial3D = pumpkin_orange_jackolantern.get_active_material(1)
	return stm

func splat():
	Audio.play("audio/splat.ogg", true, global_transform)
	
	var broken_model_instance = broken_model.instantiate()
	broken_model_instance.transform = self.transform
	get_parent().add_child(broken_model_instance)
	
	vfx_instance.transform = self.transform
	get_parent().add_child(vfx_instance)
	var children = vfx_instance.get_children()
	for child:GPUParticles3D in children:
		child.emitting = true
	
	# decal
	splat_decal_instance.transform = self.transform
	splat_decal_instance.position.y = 0.0
	splat_decal_instance.time = 4.0
	get_parent().add_child(splat_decal_instance)
	
	self.queue_free()
