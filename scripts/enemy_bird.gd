extends Area2D

# Simple falling obstacle (“bird”).
#
# Collision: Area2D on layer 2, mask 1 (player). We add the node to the
# "enemy" group so the spawner can cap the number of concurrent enemies.

@export var speed: float = 180.0
# If true, scale the visual to (roughly) match the collision box
@export var match_visual_to_collision: bool = true
@export var visual_inset_px: float = 0.0  # positive shrinks a touch for fairness

func _ready():
	monitoring = true
	add_to_group("enemy")
	connect("body_entered", _on_body_entered)
	if match_visual_to_collision:
		_fit_visual_to_collision()

func _process(delta):
	if Global.state != "RUNNING":
		return
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player" and Global.alive:
		Global.alive = false
		Global.state = "DEAD"

# Attempts to scale any Sprite2D visual to match the RectangleShape2D size.
# Falls back to updating a Polygon2D rectangle if present.
func _fit_visual_to_collision():
	var cs: CollisionShape2D = $CollisionShape2D
	if cs and cs.shape is RectangleShape2D:
		var target: Vector2 = (cs.shape as RectangleShape2D).size
		# Apply a tiny inset if desired, but keep positive dimensions
		target.x = max(1.0, target.x - visual_inset_px)
		target.y = max(1.0, target.y - visual_inset_px)
		# Try Sprite2D first
		var sprite := get_node_or_null("Sprite2D")
		if sprite and sprite is Sprite2D and sprite.texture:
			var tex_size: Vector2 = sprite.texture.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				sprite.scale = Vector2(target.x / tex_size.x, target.y / tex_size.y)
				return
		# Otherwise, try a Polygon2D rectangle named "Rect"
		var poly := get_node_or_null("Rect")
		if poly and poly is Polygon2D:
			var w := target.x
			var h := target.y
			(poly as Polygon2D).polygon = PackedVector2Array([
				Vector2(-w/2.0, -h/2.0),
				Vector2( w/2.0, -h/2.0),
				Vector2( w/2.0,  h/2.0),
				Vector2(-w/2.0,  h/2.0)
			])
