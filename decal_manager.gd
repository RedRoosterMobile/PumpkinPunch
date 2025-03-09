extends Node3D

@export var splat_decal: PackedScene = preload("res://splat_decal.tscn")
@export var max_decals: int = 10
var decal_pool: Array = []

func _ready() -> void:
	for i in range(max_decals):
		var decal = splat_decal.instantiate()
		decal.visible = false
		add_child(decal)
		decal_pool.append(decal)

func get_free_decal() -> Decal:
	for decal in decal_pool:
		if not decal.visible:
			return decal
	var oldest_decal = decal_pool.pop_front()
	decal_pool.append(oldest_decal)
	return oldest_decal

func _on_spawn_decal_requested(position: Vector3) -> void:
	var decal = get_free_decal()
	if decal:
		decal.global_position = position
		decal.global_position.y = 0.01
		decal.modulate.a = 1.0  # Reset alpha to fully visible
		decal.visible = true
		fade_decal(decal)

func fade_decal(decal: Decal) -> void:
	# Calculate fade timing (from your original Decal script)
	var fade_start_time = 4.0 * 0.8  # 80% of 4 seconds
	var fade_duration = 4.0 * 0.2    # 20% of 4 seconds
	
	await get_tree().create_timer(fade_start_time).timeout
	
	var tween = create_tween()
	tween.tween_property(decal, "modulate:a", 0.0, fade_duration)
	await tween.finished
	decal.visible = false  # Hide it, don’t free it
