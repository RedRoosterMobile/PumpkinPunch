extends Node3D

@export var broken_model:PackedScene
@export var vfx:PackedScene = preload("res://vfx_hit.tscn")

var vfx_instance

func _ready() -> void:
	vfx_instance = vfx.instantiate()

func _unhandled_inputt(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		splat()

func splat():
	var children = vfx_instance.get_children()
	for child:GPUParticles3D in children:
		child.emitting = true
	Audio.play("audio/splat.ogg", true, global_transform)
	
	# only do 2 or 3 max on screen ()
	var broken_model_instance = broken_model.instantiate()
	
	broken_model_instance.transform = self.transform
	get_parent().add_child(broken_model_instance)
	vfx_instance.transform = self.transform
	get_parent().add_child(vfx_instance)
	
	self.queue_free()
