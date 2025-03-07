extends RichTextLabel

func _process(delta: float) -> void:
	text = str(int(1 / delta)) + " fps"
