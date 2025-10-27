extends Node2D

# Central spawner that emits enemies and collectibles from the top of the
# screen. Parameters are exported for quick tuning during the jam.

@export var enabled: bool = true
@export var x_min: float = 80.0         # left spawn bound in pixels
@export var x_max: float = 1200.0       # right spawn bound in pixels
@export var y_spawn: float = -40.0      # slightly above viewport

@export var enemy_scenes: Array[PackedScene]
@export var collectible_scene: PackedScene

# Difficulty parameters control the spawn intervals as they approach
# their minimums over time (simple ramp).
@export var spawn_interval_start: float = 1.4
@export var spawn_interval_min: float = 0.55
@export var spawn_interval_accel: float = 0.02  # seconds decreased per second

@export var collectible_interval_start: float = 2.3
@export var collectible_interval_min: float = 1.0
@export var collectible_interval_accel: float = 0.01

@export var max_simultaneous_enemies: int = 10

var enemy_interval := spawn_interval_start
var collect_interval := collectible_interval_start
var t_enemy := 0.0
var t_collect := 0.0

func _ready():
	enemy_interval = spawn_interval_start
	collect_interval = collectible_interval_start

	# Fit spawn bounds to current viewport so spawns are on-screen,
	# regardless of user window size.
	var w = get_viewport_rect().size.x
	x_min = clamp(x_min, 0.0, w)
	x_max = clamp(x_max, 0.0, w)
	if x_min > x_max:
		var tmp = x_min
		x_min = x_max
		x_max = tmp

	# Spawn one enemy on the first frame so players immediately see action.
	call_deferred("_spawn_enemy_once")

func _process(delta):
	if not enabled or Global.state != "RUNNING":
		return

	# Difficulty ramp: intervals gently approach their minima.
	enemy_interval = max(spawn_interval_min, enemy_interval - spawn_interval_accel * delta)
	collect_interval = max(collectible_interval_min, collect_interval - collectible_interval_accel * delta)

	t_enemy += delta
	t_collect += delta

	if t_enemy >= enemy_interval and enemy_scenes.size() > 0:
		if get_tree().get_nodes_in_group("enemy").size() < max_simultaneous_enemies:
			t_enemy = 0.0
			_spawn_enemy_once()
		else:
			# defer next try a bit if capped
			t_enemy = enemy_interval * 0.5

	if collectible_scene and t_collect >= collect_interval:
		t_collect = 0.0
		var c = collectible_scene.instantiate()
		c.position = Vector2(randf_range(x_min, x_max), y_spawn)
		add_child(c)

func _spawn_enemy_once():
	# Instantiates a random enemy scene and drops it from the top.
	if enemy_scenes.size() == 0:
		return
	var scn: PackedScene = enemy_scenes.pick_random()
	var e = scn.instantiate()
	# Randomize speed a bit if the script exports a `speed` property.
	var has_speed := false
	for p in e.get_property_list():
		if p.name == "speed":
			has_speed = true
			break
	if has_speed:
		e.speed *= randf_range(0.95, 1.15)
	e.position = Vector2(randf_range(x_min, x_max), y_spawn)
	add_child(e)
