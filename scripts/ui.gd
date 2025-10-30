extends CanvasLayer

# Heads-up display for the run and a simple Game Over overlay.
#
# - Labels at top-left show live Score (meters) and Mars Bars collected.
# - When the game enters DEAD state, we show an overlay that displays final
#   stats and offers Retry (back to the boost gauge) and Menu.

func _ready():
	# Wire Game Over buttons (if present)
	var retry = null
	if has_node("Overlay/Center/VBox/Buttons/RetryButton"):
		retry = $Overlay/Center/VBox/Buttons/RetryButton
		retry.pressed.connect(_on_retry_pressed)
	var menu = null
	if has_node("Overlay/Center/VBox/Buttons/MenuButton"):
		menu = $Overlay/Center/VBox/Buttons/MenuButton
		menu.pressed.connect(_on_menu_pressed)

func _process(_delta):
	$MarginContainer/VBoxContainer/ScoreLabel.text = "Score: %d m" % Global.score
	$MarginContainer/VBoxContainer/MarsLabel.text  = "Mars Bars: %d" % Global.mars_bars
	var boost_label := $MarginContainer/VBoxContainer/BoostLabel as Label
	if Global.boost_time_left > 0.0:
		boost_label.visible = true
		boost_label.text = "Boost: %.1fs" % Global.boost_time_left
	else:
		boost_label.visible = false
	var overlay := $Overlay as Control
	if Global.state == "DEAD":
		overlay.visible = true
		var final_label: Label = overlay.get_node("Center/VBox/Final")
		final_label.text = "Score: %d m  Mars Bars: %d" % [Global.score, Global.mars_bars]
	else:
		overlay.visible = false

func _unhandled_input(event):
	# Fallback: clicking anywhere on DEAD returns to Menu (kept for convenience)
	if Global.state == "DEAD" and event.is_action_pressed("click"):
		_on_menu_pressed()

func _on_retry_pressed():
	Global.state = "INTRO"
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_menu_pressed():
	Global.state = "MENU"
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
