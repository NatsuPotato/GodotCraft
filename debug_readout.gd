extends RichTextLabel

@export var PLAYER : CharacterBody3D

func _process(delta: float) -> void:
	text = str(int(1 / delta)) + " fps " + str(PLAYER.position)
