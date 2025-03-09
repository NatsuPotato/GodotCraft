extends Node

var is_paused := true

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		UiState.is_paused = !UiState.is_paused
		
		if UiState.is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
