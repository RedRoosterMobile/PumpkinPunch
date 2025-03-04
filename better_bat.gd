extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("current animation")
	print(animation_player.current_animation)
	animation_player.play("ArmatureAction")
