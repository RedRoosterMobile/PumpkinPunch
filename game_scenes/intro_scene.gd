extends XRToolsSceneBase

@onready var story_segment: Node3D = $StorySegment
@onready var image_display: MeshInstance3D = $StorySegment/MeshInstance3D  # Adjust the path
@onready var story_label: Label3D = $StorySegment/Label3D          # Adjust the path

@export var story_array: Array[StoryData] = []  # Editable in the inspector
var original_image_pos: Vector3  # Store original position of image_display
var original_label_pos: Vector3  # Store original position of story_label
@onready var xr_origin_3d: XROrigin3D = $XROrigin3D
var current_index:int=0

var controller_left : XRController3D
var controller_right : XRController3D
func _ready() -> void:
	print("howdy")
	
	# Check if nodes are valid
	if not story_segment or not image_display or not story_label:
		push_error("One or more nodes are not found in the scene tree!")
		return
	
	# No need to populate here; it will be done in the inspector
	if story_array.size() == 0:
		push_warning("No story data found in story_array. Please add entries in the inspector.")
		
	# Store original positions
	original_image_pos = image_display.position
	original_label_pos = story_label.position
	story_segment.visible = false
	# Display the first story segment (if any)
	if story_array.size() > 0:
		display_story_segment(current_index)
		controller_left = XRHelpers.get_xr_controller(xr_origin_3d.get_child(1))
	if controller_left:
		controller_left.button_pressed.connect(_on_button_pressed)
			
	controller_right = XRHelpers.get_xr_controller(xr_origin_3d.get_child(2))
	if controller_right:
		controller_right.button_pressed.connect(_on_button_pressed)


func display_story_segment(index: int) -> void:
	if index < 0 or index >= story_array.size():
		print("Invalid story segment index")
		return
	
	var current_story: StoryData = story_array[index]
	
	# Debug: Check if current_story is valid
	if not current_story:
		print("Current story is null at index: " + str(index))
		return
	
	# Update the image and story
	if story_label and image_display and image_display.get_active_material(0) and current_story.image and current_story.story:
		
		set_next(current_story.image,current_story.story)
	else:
		push_error("Failed to update image: Check material or image data")


func set_next(image: Texture2D, story: String) -> void:
	# Create a new Tween
	var tween: Tween = create_tween()
	
	# Define animation targets (move image left, label right)
	var target_image_pos = original_image_pos - Vector3(10.0, 0, 0)  # Move 2 units left (adjust as needed)
	var target_label_pos = original_label_pos + Vector3(10.0, 0, 0)  # Move 2 units right (adjust as needed)
	
	# Animate image_display to the left
	tween.tween_property(image_display, "position", target_image_pos, 0.5) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	
	# Animate story_label to the right
	tween.tween_property(story_label, "position", target_label_pos, 0.5) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	
	# Wait for the animations to complete (0.5 seconds)
	tween.tween_interval(0.5)
	
	# Set new data (update texture and text)
	tween.tween_callback(func():
		story_segment.visible = true
		if image_display and image_display.get_active_material(0):
			image_display.get_active_material(0).albedo_texture = image
		if story_label:
			story_label.text = story
	)
	
	
	# Animate both back to original positions
	tween.tween_property(image_display, "position", original_image_pos, 0.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(story_label, "position", original_label_pos, 0.5) \
		.set_ease(Tween.EASE_IN) \
		.set_trans(Tween.TRANS_CUBIC)

func _on_button_pressed(button_name: String) -> void:
	# check: openXR action map at the bottom e.g. "trigger_click", "grip_click"
	if story_array.size() > current_index:
		current_index+=1
		display_story_segment(current_index)
	else:
		var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
		if not scene_base:
			return
		# Request loading the next scene
		scene_base.load_scene("res://game_scenes/game_scene.tscn")
