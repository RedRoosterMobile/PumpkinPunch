extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("Armature_spider_001|spider_stand")
