extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var play_on_start:bool = false

func _ready() -> void:
	print("current animation")
	print(animation_player.current_animation)
	if (play_on_start):
		animation_player.play("ArmatureAction")
