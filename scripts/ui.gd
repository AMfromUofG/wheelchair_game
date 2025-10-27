extends CanvasLayer

# Heads‑up display for the run and a simple Game Over overlay.
#
# - Labels at top-left show live Score (meters) and Mars Bars collected.
# - When the game enters DEAD state, we show an overlay that displays final
#   stats and listens for a click to return to the Menu.

func _process(_delta):
	$MarginContainer/VBoxContainer/ScoreLabel.text = "Score: %d m" % Global.score
	$MarginContainer/VBoxContainer/MarsLabel.text  = "Mars Bars: %d" % Global.mars_bars
	var overlay := $Overlay as Control
	if Global.state == "DEAD":
		overlay.visible = true
		var final_label: Label = overlay.get_node("Center/VBox/Final")
		final_label.text = "Score: %d m  Mars Bars: %d" % [Global.score, Global.mars_bars]
	else:
		overlay.visible = false

func _unhandled_input(event):
	if Global.state == "DEAD" and event.is_action_pressed("click"):
		Global.state = "MENU"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
