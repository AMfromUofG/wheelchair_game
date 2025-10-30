extends Control

signal locked(value_ratio: float)

@onready var bg: ColorRect = $Bg
@onready var base_tex: TextureRect = $"Bg/Base"
@onready var cursor: TextureRect = $"Bg/Cursor"

@export var bar_size: Vector2 = Vector2(400, 22)
@export var slider_speed_px: float = 300.0  # pixels per second

# Cursor atlas region (crop around the yellow indicator). Adjust as needed.
@export var cursor_region: Rect2i = Rect2i(240, 0, 6, 16)
# Optional: a wider stripe for subtle gradient base
@export var base_region: Rect2i = Rect2i(0, 0, 256, 16)

var _dir := 1.0
var _is_locked := false
var _travel_min := 0.0
var _travel_max := 0.0

func _ready():
	# Size the root to fit the bar plus padding; let the VBox center this node.
	var pad := Vector2(0, 0)
	set_custom_minimum_size(bar_size + pad)
	bg.size = bar_size
	# Center within this control (which the VBox centers under the title)
	bg.position = Vector2.ZERO

	# Load spritesheet once
	var sheet: Texture2D = load("res://assets/gauge_horizontal_colored_bar.png")
	if sheet:
		# Static base (scaled to bar width). Crop inside to avoid the black border.
		var base_atlas := AtlasTexture.new()
		base_atlas.atlas = sheet
		var tex_size: Vector2i = Vector2i(sheet.get_size())
		var inset := 2
		var region := Rect2i(inset, inset, max(1, tex_size.x - inset*2), max(1, tex_size.y - inset*2))
		base_atlas.region = region
		base_tex.texture = base_atlas
		base_tex.size = bg.size
		base_tex.position = Vector2.ZERO
		# Cursor cropped to small yellow region, scaled to full bar height
		var cur_atlas := AtlasTexture.new()
		cur_atlas.atlas = sheet
		cur_atlas.region = cursor_region
		cursor.texture = cur_atlas
		cursor.size = Vector2(cursor_region.size.x, bar_size.y)
		cursor.position = Vector2.ZERO

	_travel_min = 0.0
	_travel_max = bg.size.x - cursor.size.x
	set_process(true)

func _process(delta: float) -> void:
	if _is_locked:
		return
	var x := cursor.position.x + _dir * slider_speed_px * delta
	if x >= _travel_max:
		x = _travel_max
		_dir = -1.0
	elif x <= _travel_min:
		x = _travel_min
		_dir = 1.0
	cursor.position.x = x

func _input(event: InputEvent) -> void:
	if _is_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		_is_locked = true
		var ratio := 0.0
		if _travel_max > _travel_min:
			ratio = (cursor.position.x - _travel_min) / (_travel_max - _travel_min)
		locked.emit(ratio)
