extends Control

# Minimal “boost gauge” intro. It’s intentionally simple for the jam:
#
# - Shows a ping‑ponging value (0..100%).
# - On click/space/enter we convert the current gauge position such that
#   clicking near the center gives the best boost (2.0), edges are worst (1.0).
# - We store the boost in Global and go to the Main scene.

@export var speed: float = 1.8  # cycles per second (ping-pong)

var t: float = 0.0
var forward := true

func _ready():
	Global.state = "INTRO"
	# start with neutral boost; Menu already reset these values
	t = 0.0

func _process(delta: float):
	# Animate gauge ping-pong 0..100
	var gauge: TextureProgressBar = $Margin/VBox/Gauge
	var val: float = gauge.value
	var step: float = speed * 100.0 * delta
	if forward:
		val += step
		if val >= 100.0:
			val = 100.0
			forward = false
	else:
		val -= step
		if val <= 0.0:
			val = 0.0
			forward = true
	gauge.value = val

func _input(event):
	# Accept mouse click anywhere or Enter/Space as confirm
	if event.is_action_pressed("click"):
		_lock_in()
	elif event is InputEventMouseButton and event.pressed:
		_lock_in()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
		_lock_in()

func _lock_in():
	var gauge: TextureProgressBar = $Margin/VBox/Gauge
	# If the gauge isn’t ready (shouldn’t happen), default to 1.5 boost to keep flow simple.
	var v: float = (gauge.value if is_instance_valid(gauge) else 50.0) / 100.0
	# Map so best is center (0.5); dist from center 0..1
	var dist_center: float = abs(v - 0.5) * 2.0
	var boost: float = 2.0 - dist_center  # 1..2 (2 best)
	Global.boost = clamp(boost, 1.0, 2.0)
	Global.state = "RUNNING"
	get_tree().change_scene_to_file("res://scenes/main.tscn")
