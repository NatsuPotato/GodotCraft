extends CharacterBody3D

@export var camera : Camera3D
@export var mouse_sensitivity = 0.3
var camera_anglev = 0

#Input.is_action_just_pressed("ui_accept")

func _process(delta: float) -> void:
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity += get_gravity() * delta
	
	if direction:
		velocity.x = direction.x * 10
		velocity.z = direction.z * 10
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()

# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	
	if event is InputEventMouseMotion:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		var changev = -event.relative.y * mouse_sensitivity
		
		if abs(camera_anglev + changev) < 50:
			camera_anglev += changev
			camera.rotation.x += deg_to_rad(changev)
