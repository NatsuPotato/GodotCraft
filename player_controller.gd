extends CharacterBody3D

@export var camera : Camera3D
@export var mouse_sensitivity := 0.3
@export var walk_speed := 5
@export var jump_speed := 5

var camera_pitch := 0.0

# TODO add a simple pause menu (pause input + mouse capturing)

func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("use")):
		
		var result := raycast(10)
		
		if (!result.is_empty()):
			
			result.collider.set_tile_type(result.collider.get_tile_pos_from_raycast(result, true), 1)
	
	if (Input.is_action_just_pressed("hit")):
		
		var result := raycast(10)
		
		if (!result.is_empty()):
			
			result.collider.set_tile_type(result.collider.get_tile_pos_from_raycast(result, false), 0)
	
	
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "strafe_forward", "strafe_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()

# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func raycast(length:int) -> Dictionary:
	
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + length * -camera.get_global_transform().basis.z)
	return space_state.intersect_ray(query)

func _input(event):
	
	if event is InputEventMouseMotion:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		camera.rotation.x = deg_to_rad(camera_pitch)
