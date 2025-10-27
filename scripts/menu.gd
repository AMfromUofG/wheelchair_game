extends Control

# Entry point. Very small scene whose only job is to:
# 1) Reset run-local values
# 2) Mark state as MENU (for clarity)
# 3) Navigate to the Intro scene when the user presses Play

func _ready():
    Global.reset()
    Global.state = "MENU"
    var btn: Button = $Center/VBox/PlayButton
    btn.pressed.connect(_on_play)

func _on_play():
    # Intro computes the starting boost and then switches to Main.
    Global.state = "INTRO"
    get_tree().change_scene_to_file("res://scenes/intro.tscn")
