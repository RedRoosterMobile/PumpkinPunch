extends MeshInstance3D
var mat: ShaderMaterial
const glow_param = "glow"
func _ready() -> void:
	mat = get_active_material(0)

var time: float = 0.0
func _process(delta: float) -> void:
	var ztoo = sin(time*1.5)*0.5+0.5
	mat.set_shader_parameter(glow_param,1.0+ztoo*1.5)
	time += delta
