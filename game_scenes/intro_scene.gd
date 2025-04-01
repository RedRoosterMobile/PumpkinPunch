extends XRToolsSceneBase

@onready var story_segment: Node3D = $StorySegment
@onready var image_display: MeshInstance3D = $StorySegment/MeshInstance3D
@onready var story_label: Label3D = $StorySegment/Label3D

@export var fade_speed: float = 1.0
@export var fade_distance: float = 2.5
@export var story_array: Array[StoryData] = []
var original_image_pos: Vector3
var original_label_pos: Vector3
@onready var xr_origin_3d: XROrigin3D = $XROrigin3D
var current_index: int = 0

var controller_left: XRController3D
var controller_right: XRController3D
var is_animating: bool = false  # Flag to prevent overlapping animations

func _ready() -> void:
	print("howdy, story_array size: ", story_array.size())
	
	if not story_segment or not image_display or not story_label:
		push_error("One or more nodes are not found in the scene tree!")
		return
	
	original_image_pos = image_display.position
	original_label_pos = story_label.position
	story_segment.visible = false
	
	if story_array.size() > 0:
		display_story_segment(current_index)
		controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
		if controller_left:
			controller_left.button_pressed.connect(_on_button_pressed)
			
		controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
		if controller_right:
			controller_right.button_pressed.connect(_on_button_pressed)
	else:
		push_warning("No story data found in story_array.")

func display_story_segment(index: int) -> void:
	if index < 0 or index >= story_array.size():
		print("Invalid story segment index: ", index, " array size: ", story_array.size())
		return
	
	var current_story: StoryData = story_array[index]
	
	if not current_story:
		print("Current story is null at index: ", index)
		return
	
	print("Displaying story at index: ", index)
	set_next(current_story.image, current_story.story)

func set_next(image: Texture2D, story: String) -> void:
	if is_animating:
		print("Skipping animation: already in progress at index ", current_index)
		return
	
	is_animating = true
	
	var tween_image: Tween = create_tween()
	var tween_story: Tween = create_tween()
	
	print("Setting next story at index: ", current_index)
	
	var target_image_pos = original_image_pos - Vector3(fade_distance, 0, 0)
	var target_label_pos = original_label_pos + Vector3(fade_distance, 0, 0)
	
	# Animate out
	tween_image.tween_property(image_display, "position", target_image_pos, fade_speed) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUART)
	
	tween_story.tween_property(story_label, "position", target_label_pos, fade_speed) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUART)
	
	# Set new data after moving out
	tween_image.tween_callback(func():
		if image_display and image_display.get_active_material(0):
			image_display.get_active_material(0).albedo_texture = image
		if story_label:
			story_label.text = story
		story_segment.visible = true
	)
	
	# Animate back
	tween_image.tween_property(image_display, "position", original_image_pos, fade_speed) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUART)
	
	tween_story.tween_property(story_label, "position", original_label_pos, fade_speed) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_QUART)
	
	# Mark animation as complete when all tweens are done
	tween_image.tween_callback(func(): is_animating = false)

func _on_button_pressed(button_name: String) -> void:
	print("Button pressed, current_index before: ", current_index, " array size: ", story_array.size(), " is_animating: ", is_animating)
	if story_array.size() > 0 and not is_animating:
		current_index += 1
		if current_index >= story_array.size():
			var scene_base: XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
			if scene_base:
				print("Loading next scene...")
				scene_base.load_scene("res://game_scenes/game_scene.tscn")
			else:
				print("No scene base found, looping back to start")
				current_index = 0
		print("After increment, new index: ", current_index)
		display_story_segment(current_index)
	else:
		if story_array.size() == 0:
			push_warning("No story data available in story_array.")
		else:
			print("Animation in progress, waiting...")
