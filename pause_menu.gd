extends Control

func _process(delta: float) -> void:
	visible = UiState.is_paused
