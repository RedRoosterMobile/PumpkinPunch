extends Node3D

@export var broken_model:PackedScene

func _unhandled_inputt(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		splat()

func splat():
	Audio.play("audio/splat.ogg", true, global_transform)
	var broken_model_intance = broken_model.instantiate()
	print(broken_model_intance)
	
	broken_model_intance.transform = self.transform
	get_parent().add_child(broken_model_intance)
	
	self.queue_free()
