extends CharacterBody2D

# Horizontal-only character (wheelchair) controlled with A/D or left/right.
#
# - Movement has a tiny acceleration/lerp for feel.
# - Horizontal speed is multiplied by the global boost set in Intro.
# - We clamp position to stay within the visible area.

@export var speed: float = 220.0
var target_dir := 0.0
var accel := 8.0

func _physics_process(delta):
	if Global.state != "RUNNING":
		velocity = Vector2.ZERO
		return

	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0
	if Input.is_action_pressed("move_right"):
		dir += 1.0

	# tiny easing so keyboard movement feels less binary
	target_dir = lerp(target_dir, dir, clamp(accel * delta, 0.0, 1.0))
	velocity.x = target_dir * speed * Global.boost
	velocity.y = 0.0
	move_and_slide()

	# Keep player within viewport bounds
	var rect = get_viewport_rect()
	position.x = clamp(position.x, 60.0, rect.size.x - 60.0)
