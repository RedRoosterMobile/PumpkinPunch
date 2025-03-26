extends Node3D
@onready var score: Label3D = $Score
@export var bad_color:Color = Color(1,0,0,1)
@export var good_color:Color = Color(0,1,0,1)

var original_color: Color
var original_scale: Vector3

func _ready() -> void:
	Messenger.add_score.connect(add_score)
	original_color = score.modulate
	original_scale = score.scale

func add_score(score_value:int) -> void:
	GameState.score += score_value
	score.text = str(GameState.score)
	animate_score(score_value)

# FIXME: this does the wiggle and explosions, colors, pizazz
var score_tween: Tween = null
func animate_score(score_value):
	# Kill any existing tween if it exists
	if score_tween != null:
		score_tween.kill()
	
	# Create a new tween and store it
	score_tween = create_tween()
	# Configure tween behavior (optional)
	score_tween.set_ease(Tween.EASE_OUT)  # Makes animation smoother
	score_tween.set_trans(Tween.TRANS_QUAD)  # Quadratic transition
	
	# Scale up
	score_tween.tween_property(
		score,           # Target node
		"scale",         # Property to animate
		original_scale * 1.5,   # Target scale value
		0.15             # Duration
	)
	# Color change
	score_tween.tween_property(
		score,           # Target node
		"modulate",      # Property to animate
		bad_color if score_value < 0 else good_color,   # Target color value
		0.15             # Duration
	)
	
	# Scale back down
	score_tween.tween_property(
		score,
		"scale",
		original_scale,   # Back to original size
		0.15
	)
	score_tween.tween_property(
		score,         
		"modulate",    
		original_color,
		0.15           
	)
