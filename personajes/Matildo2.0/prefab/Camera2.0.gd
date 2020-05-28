extends Camera
  
const ray_length = 1000

onready var player = get_parent()
var offset : Vector3

export var distance = -4
export var heigth = 5


func _init():
	# Make parent independent
	set_as_toplevel(true)
		
func _ready():
	
	# Connect signals to the global node
	GlobalVariables.connect("s_move", GlobalVariables, "_on_Controller_s_move")
	
	
	offset = get_global_transform().origin
	offset.x = distance
	offset.y = heigth
	offset.z = 0
	
#	
func _input(event):
	
	# Move to Any point PRESSED in the world
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * ray_length
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [], 1)
		if result:
			
			# Update path to wherever is clicked
			get_tree().call_group("units", "update_path", result.position)
			GlobalVariables.move = true
			
			# Moving, emit correspondig signal
			GlobalVariables.emit_signal("s_move")
			
		
	#---------------------------------------------------------------------------
	#---------------------------------------------------------------------------
	# Zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				print(fov)
				if fov > 30:
					fov -= 1.5
				
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				print(fov)
				if fov < 80:
					fov += 1.5				
		
			
# Follow the player
func _physics_process(delta):
	var target = get_parent().get_global_transform().origin
	var pos = target + offset
	var up = Vector3(0, 1, 0)
	look_at_from_position(pos, target, up)
