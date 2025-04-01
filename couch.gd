extends Node3D

@onready var sofa_3d_2: Node3D = $sofa3d2

func _ready() -> void:
	fix_roughness(sofa_3d_2.get_child(0))
	fix_roughness(sofa_3d_2.get_child(1))
	pass
	
func fix_roughness(mesh: MeshInstance3D):
	print(mesh.get_active_material(0))
	var mat: StandardMaterial3D = mesh.get_active_material(0)
	mat.roughness = 0.96
