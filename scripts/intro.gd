extends Control

# Intro scene that hosts the Gauge component and maps the locked value
# to a starting boost before entering gameplay.

func _ready():
    Global.state = "INTRO"
    var gauge = $Margin/VBox/Gauge
    if gauge and gauge.has_signal("locked"):
        gauge.locked.connect(_on_gauge_locked)

func _on_gauge_locked(ratio: float):
    # Map rightmost = strongest/longest boost.
    # Duration 0..10s from left..right.
    Global.boost_time_left = clamp(10.0 * ratio, 0.0, 10.0)
    # During boost: 5x speed + invincibility.
    if Global.boost_time_left > 0.0:
        Global.boost = 5.0
        Global.invincible = true
    else:
        Global.boost = 1.0
        Global.invincible = false
    Global.state = "RUNNING"
    get_tree().change_scene_to_file("res://scenes/main.tscn")
