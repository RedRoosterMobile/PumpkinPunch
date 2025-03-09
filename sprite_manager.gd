extends Node

@export var splat_sprite: PackedScene = preload("res://splat_sprite.tscn")
@export var max_sprites: int = 10
var sprite_pool: Array = []

func _ready() -> void:
	for i in range(max_sprites):
		var sprite = splat_sprite.instantiate()
		sprite.visible = false
		add_child(sprite)
		sprite_pool.append(sprite)
	print("Sprite pool initialized with ", sprite_pool.size(), " sprites")

func get_free_sprite() -> Sprite3D:
	for sprite in sprite_pool:
		if not sprite.visible:
			return sprite
	var oldest_sprite = sprite_pool.pop_front()
	sprite_pool.append(oldest_sprite)
	return oldest_sprite

func _on_spawn_splat_requested(position: Vector3) -> void:
	var sprite = get_free_sprite()
	if sprite:
		sprite.global_position = position
		sprite.global_position.y = 0.01  # Slightly above ground
		sprite.modulate.a = 1.0
		sprite.visible = true
		fade_sprite(sprite)

func fade_sprite(sprite: Sprite3D) -> void:
	var fade_start_time = 4.0 * 0.8  # 80% of 4 seconds
	var fade_duration = 4.0 * 0.2    # 20% of 4 seconds
	await get_tree().create_timer(fade_start_time).timeout
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, fade_duration)
	await tween.finished
	sprite.visible = false
