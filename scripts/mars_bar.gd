extends Area2D

# Falling collectible (Mars bar).
# Collision: Area2D on layer 3, mask 1 (player). When picked up, it
# increments `Global.mars_bars` and destroys itself.

@export var speed: float = 160.0

func _ready():
	monitoring = true
	add_to_group("collectible")
	connect("body_entered", _on_body_entered)

func _process(delta):
	if Global.state != "RUNNING":
		return
	position.y += speed * Global.boost * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		Global.mars_bars += 1
		queue_free()
