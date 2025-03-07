extends Camera3D

@export var fly_speed = 5
@export var mouse_sensitivity = 0.3
var camera_anglev = 0

#get_gravity()
#Input.is_action_just_pressed("ui_accept")

func _process(delta: float) -> void:
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		position += direction * fly_speed * delta

# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	
	if event is InputEventMouseMotion:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		var changev = -event.relative.y * mouse_sensitivity
		
		if abs(camera_anglev + changev) < 50:
			camera_anglev += changev
			rotation.x += deg_to_rad(changev)
