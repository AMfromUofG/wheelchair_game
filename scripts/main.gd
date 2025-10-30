extends Node2D

# Main gameplay scene controller.
#
# Responsibilities
# - Initializes a new run while preserving the boost selected in Intro.
# - Maintains the score counter based on background scroll speed.
# - Handles click-to-menu on death.

@export var pixels_per_meter: float = 60.0  # pixels per 1 meter (tweak to taste)

@onready var bg = $Background
@onready var spawner = $EntitySpawner

# Accumulator to keep score smooth and frame-rate independent.
var meters_accum: float = 0.0

func _ready():
	# Preserve intro boost state (timed) if present, then reset the rest.
	var boost_chosen := Global.boost
	var inv_chosen := Global.invincible
	var time_left := Global.boost_time_left
	Global.reset()
	if time_left > 0.0:
		Global.boost_time_left = time_left
		Global.boost = max(1.0, boost_chosen)
		Global.invincible = inv_chosen
	elif boost_chosen > 1.0:
		Global.boost = boost_chosen
	Global.alive = true
	Global.state = "RUNNING"

	# Ensure spawner enabled on entry (in case it was disabled in editor).
	if spawner:
		spawner.enabled = true

func _process(delta):
	if Global.state != "RUNNING":
		return
	# Handle timed boost countdown and auto-clear
	if Global.boost_time_left > 0.0:
		Global.boost_time_left = max(0.0, Global.boost_time_left - delta)
		if Global.boost_time_left == 0.0:
			Global.boost = 1.0
			Global.invincible = false
	# Score increases with background scroll speed. Accumulate as float,
	# then write the integer meters to Global so the HUD stays clean.
	var bg_speed := 0.0
	if bg:
		# background.gd exports scroll_speed; read directly if present
		bg_speed = bg.scroll_speed if "scroll_speed" in bg else 0.0
	# Apply boost multiplier so distance matches on-screen movement
	var effective_speed := bg_speed * Global.boost
	meters_accum += (effective_speed / pixels_per_meter) * delta
	Global.score = int(meters_accum)

func _unhandled_input(event):
	# After death, a click returns to the Menu (hard reset of flow).
	if Global.state == "DEAD" and event.is_action_pressed("click"):
		Global.state = "MENU"
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
