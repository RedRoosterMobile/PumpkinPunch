extends Node3D

@export var broken_model: PackedScene
var vfx: PackedScene = preload("res://vfx_hit.tscn")
@export var splat_decal: PackedScene
@onready var pumpkin_orange_jackolantern: MeshInstance3D = $pumpkin_orange_jackolantern
@onready var hit_vfx: Node3D = $"HIT VFX"

var vfx_instance
var splat_decal_instance

func _ready() -> void:
	vfx_instance = vfx.instantiate()
	#splat_decal_instance = splat_decal.instantiate()
	var puff:AnimationPlayer = hit_vfx.get_node("AnimationPlayer")
	puff.play()
	#/Users/thomasranker/pumpkinpunch/songs/Pumpkin-hit.wav
	#Audio.play("audio/656066__ihitokage__soft-explosion-puff.mp3", true, global_transform)
	

func get_material() -> StandardMaterial3D:
	var stm: StandardMaterial3D = pumpkin_orange_jackolantern.get_active_material(1)
	return stm

func splat():
	#Audio.play("audio/splat.ogg", true, global_transform)
	Audio.play("songs/Pumpkin-hit.wav", true, global_transform)
	
	var show_splat:bool = randf_range(0.0,1.0) < 0.33;
	if (show_splat):
		var broken_model_instance = broken_model.instantiate()
		broken_model_instance.transform = self.transform
		get_parent().add_child(broken_model_instance)
	
	vfx_instance.transform = self.transform
	get_parent().add_child(vfx_instance)
	var children = vfx_instance.get_children()
	# FIXME: use animation player and thrigger that
	for child:GPUParticles3D in children:
		child.emitting = true
	
	Messenger.spawn_decal_requested.emit(global_transform.origin)
	# decal (eats into FPS if too many)
	#splat_decal_instance.transform = self.transform
	#splat_decal_instance.position.y = 0.0
	#splat_decal_instance.time = 1.0
	#get_parent().add_child(splat_decal_instance)
	
	# FIXME: send to object pool instead
	self.queue_free()
