extends Node2D

@export var segment_height: int = 720

func _process(_delta):
	for seg in [ $"SegA", $"SegB" ]:
		if seg.position.y >= segment_height:
			seg.position.y -= segment_height * 2
