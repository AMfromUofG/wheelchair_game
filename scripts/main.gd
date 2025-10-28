extends Node2D

# Main gameplay scene controller.
#
# Responsibilities
# - Initializes a new run while preserving the boost selected in Intro.
# - Maintains the score counter based on background scroll speed.
# - Handles click-to-menu on death.

@export var pixels_per_meter: float = 4.0  # maps pixels -> meters for score

@onready var bg = $Background
@onready var spawner = $EntitySpawner

func _ready():
	# Preserve intro boost if present, then reset the rest.
	var boost_chosen := Global.boost
	Global.reset()
	if boost_chosen > 1.0:
		Global.boost = boost_chosen
	Global.alive = true
	Global.state = "RUNNING"

	# Ensure spawner enabled on entry (in case it was disabled in editor).
	if spawner:
		spawner.enabled = true

func _process(delta):
	if Global.state != "RUNNING":
		return
	# Score increases with background scroll speed.
	var has_scroll := false
	if bg:
		for p in bg.get_property_list():
			if p.name == "scroll_speed":
				has_scroll = true
				break
	if has_scroll:
		Global.score += int((bg.scroll_speed / pixels_per_meter) * delta)

func _unhandled_input(event):
	# After death, a click returns to the Menu (hard reset of flow).
	if Global.state == "DEAD" and event.is_action_pressed("click"):
		Global.state = "MENU"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
