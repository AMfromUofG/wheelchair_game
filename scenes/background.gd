extends Node2D

# Keeps two identical background segments scrolling downward to fake
# an infinite runner. When a segment exits the bottom, it jumps back
# to the top to continue the loop.

@export var scroll_speed: float = 220.0          # pixels per second
@export var segment_height: int = 720            # height of one BG tile

func _process(delta):
	# Freeze when not in RUNNING (DEAD/MENU/INTRO).
	if Global.state != "RUNNING":
		return
	for seg in get_children():
		seg.position.y += scroll_speed * delta
		if seg.position.y >= segment_height:
			seg.position.y -= segment_height * 2
