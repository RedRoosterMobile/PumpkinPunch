extends RayCast3D

@export var attack_trigger:Area3D
@export var title:String
const LEFT:String = "left"
const RIGHT:String = "right"
func _process(delta: float) -> void:
	var is_blocking:bool = self.is_colliding() and self.get_collider() == attack_trigger
	if title == LEFT:
		GameState.is_left_hand_blocking = is_blocking
	elif title == RIGHT:
		GameState.is_right_hand_blocking = is_blocking
	
		# Debug display
		#$L
