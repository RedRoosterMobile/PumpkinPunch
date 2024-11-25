extends Node
# assets https://godotengine.org/asset-library/asset/2224
@onready var pointer: RigidBody3D = $Hand

# Inner class
class Pumpkin:
	var node: Node3D
	var start_position: Vector3
	var is_splattable: bool

var pumpkins:Array[Pumpkin]= []
var time:float = 0.0
var start_pos:Vector3
func _ready() -> void:
	for thing:Node in get_children():
		if thing.is_in_group("pumpkins"):
			var p = Pumpkin.new()
			p.node = thing
			p.start_position = thing.position
			p.is_splattable = false
			pumpkins.append(p)
			thing.scale *= 0.5
			start_pos = thing.position
			
	print(pumpkins)

func _physics_process(delta: float) -> void:
	time += delta
	
	create_new_pumpkin()
	follow_mouse()
	# Remove null entries from the array
	pumpkins = pumpkins.filter(func(pumpkin):
		return pumpkin != null and pumpkin.node != null
	)

	var sinner = sin(time)
	for pumpkin:Pumpkin in pumpkins:
		pumpkin.node.position.z += delta 
		#pumpkin.node.position.x = pumpkin.start_position.x + sinner 
		pumpkin.node.position.y += sinner/300 
		
		if pumpkin.node.position.z > 3:
			pumpkin.node.position.z=-5.719
		elif Input.is_action_just_pressed("ui_accept"):
			# check if in kill zone
			if pumpkin.is_splattable:
				pumpkin.node.splat()
func create_new_pumpkin():
	if Input.is_action_just_pressed("spawn"):
		print("spawn")
	pass

func _on_kill_zone_area_entered(area: Area3D) -> void:
	var pumpkin_node = area.get_parent()
	var pp = pumpkins.filter(func(pumpkin):
		return pumpkin.node == pumpkin_node
	)
	var p: Pumpkin = pp[0]
	p.is_splattable = true
	var mi:MeshInstance3D = p.node.get_child(0)
	#mi.get_active_material()
	var m : StandardMaterial3D = mi.get_active_material(0)
	var m2 : StandardMaterial3D = mi.get_active_material(1)
	#m.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;
	#m2.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;
	#print(mi)
	#print(p.node)

func _on_kill_zone_area_exited(area: Area3D) -> void:
	var pumpkin_node = area.get_parent()
	var pp = pumpkins.filter(func(pumpkin):
		return pumpkin.node == pumpkin_node
	)
	var p: Pumpkin = pp[0]
	#print(p.node)
	p.is_splattable = false
	
func follow_mouse():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return  # Ensure the camera exists
	# Get the mouse position in the viewport
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Project a ray from the camera through the mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var intersection_point = ray_origin + ray_direction
	pointer.position = intersection_point
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("splatt")
	#pointer.position=lerp(pointer.position,intersection_point,0.001)

func _on_hand_body_entered(body: Node) -> void:
	print(body)
	pass # Replace with function body.

func _on_hand_area_3d_area_entered(area: Area3D) -> void:
	print("ball hit")
	print(area)
	pass # Replace with function body.
