extends CanvasLayer

var extra_text:String = ""

func _process(delta: float) -> void:
	$Label.text = "FPS: " +  str(Engine.get_frames_per_second()) + extra_text
