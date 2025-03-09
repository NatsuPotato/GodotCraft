extends Control

func _process(_delta: float) -> void:
	visible = UiState.is_paused
