extends Node2D

@export var scroll_speed: float = 120.0
@export var segment_height: int = 720  # adjust if you picked a different size

func _process(delta):
	position.y += scroll_speed * delta
