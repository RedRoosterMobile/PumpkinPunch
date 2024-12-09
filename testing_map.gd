extends Node
# assets https://godotengine.org/asset-library/asset/2224
@export var left_hand_body: RigidBody3D 
@export var right_hand_body: RigidBody3D

@export var xr_enabled:bool = false

# Inner class
class Pumpkin:
	var node: Node3D
	var start_position: Vector3

var pumpkins:Array[Pumpkin]= []
var time:float = 0.0
var start_pos:Vector3

const PUMPKIN_Z:float = -6.0 # back/front
const PUMPKIN_X:float = 1.1 # left/right
const PUMPKIN_Y:float = 1 # up/down

# use this for spawning
const SPAWN_THING = preload("res://models/pumpkin_hollow_full_modified.tscn")
const SPAWN_THING_BROKEN = preload("res://models/pumpkin_hollow_pieces_modified.tscn")
const XR_INIT = preload("res://xr_origin_3d.tscn")
# use this for initial positions
var pumpkin_start_positions: Array[Vector3] = [
	Vector3(-1.26961, 1.08145, -2.11638),
	Vector3(0.960844, 1.08145, -2.11638),
	Vector3(-0.062555, 0.91448, -0.284467),
	Vector3(-1.18586, 1.08145, -5.71892),
	Vector3(1.11298, 1.08145, -5.71892)
]
func _ready() -> void:
	for thing:Node in get_children():
		if thing.is_in_group("pumpkins"):
			var p = Pumpkin.new()
			p.node = thing
			p.start_position = thing.position
			# pumpkin_start_positions.append(thing.position)
			pumpkins.append(p)
			thing.scale *= 0.5
			start_pos = thing.position
			
	print(pumpkin_start_positions)
	
	print("xr_controls_enabled")
	print(xr_enabled)
	var hand_area_left:Area3D = left_hand_body.get_node("HandArea3D")
	hand_area_left.connect("area_entered",_on_hand_area_3d_area_entered)
	
	var hand_area_right:Area3D = right_hand_body.get_node("HandArea3D")
	hand_area_right.connect("area_entered",_on_hand_area_3d_area_entered)
	# xr scene will add those to it's tree 
	if xr_enabled:
		var xr_origin_3d: TTT = XR_INIT.instantiate()
		xr_origin_3d.left_hand_body = left_hand_body
		xr_origin_3d.right_hand_body = right_hand_body
		add_child(xr_origin_3d)
		await get_tree().create_timer(2).timeout
		xr_origin_3d.init_hands()

func _physics_process(delta: float) -> void:
	time += delta
	
	create_new_pumpkin()
	if not xr_enabled:
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
			pumpkin.node.position.z = PUMPKIN_Z
func create_new_pumpkin():
	if Input.is_action_just_pressed("spawn"):
		print("spawn")
		var pumpkin = SPAWN_THING.instantiate()
		var pumpkin_pieces = SPAWN_THING_BROKEN
		pumpkin.scale *= 0.5
		pumpkin.rotate_y(30) # do some deg2rad things
		pumpkin.position = pumpkin_start_positions[0]
		pumpkin.broken_model = pumpkin_pieces
		add_child(pumpkin)
		var p = Pumpkin.new()
		p.node = pumpkin
		p.start_position = pumpkin.position
		pumpkins.append(p)
	pass
	
func _on_kill_zone_area_entered(area: Area3D) -> void:
	var pumpkin_node = area.get_parent()
	var pp = pumpkins.filter(func(pumpkin):
		return pumpkin.node == pumpkin_node
	)
	#var p: Pumpkin = pp[0]
	#var mi:MeshInstance3D = p.node.get_child(0)
	#mi.get_active_material()
	#var m : StandardMaterial3D = mi.get_active_material(0)
	#var m2 : StandardMaterial3D = mi.get_active_material(1)
	#m.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;
	#m2.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;
	#print(mi)
	#print(p.node)

func _on_kill_zone_area_exited(area: Area3D) -> void:
	var pumpkin_node = area.get_parent()
	var pp = pumpkins.filter(func(pumpkin):
		return pumpkin.node == pumpkin_node
	)
	#var p: Pumpkin = pp[0]
	#print(p.node)
	
func follow_mouse():
	# todo: only if not XR
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return  # Ensure the camera exists
	# Get the mouse position in the viewport
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Project a ray from the camera through the mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var intersection_point = ray_origin + ray_direction
	if left_hand_body:
		left_hand_body.position = intersection_point

func _on_hand_area_3d_area_entered(area: Area3D) -> void:
	print("ball hit")
	print(area.get_parent())
	if area.get_parent().is_in_group("pumpkins"):
		area.get_parent().splat()

func spawn_pumpkin():
	# z -6
	# x 1.1 / -1.11
	pass
	
# dynamically load pumpkins:
# on ready:
# - spawn pumpkins with position
# - add to array of custom class
# process:
# - filter destroyed pumpkins
# - add more if below limit
# - move them forward or reset if behind threshold
# physica handler of glove:
# - delete touched pumpkin
# - delete reference from array

# with music:
# - spawn them on midi notes
# - TBD
