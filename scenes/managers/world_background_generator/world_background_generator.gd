extends Control
class_name WorldBackgroundGenerator

@export var _texture: Texture2D
@export var min_distance: float = 30.0
@export var exclusion_radius: float = 80.0
@export var max_attempts: int = 30
@export var item_scale_range: Vector2 = Vector2(0.8, 1.2)
@export var item_rotation_range: float = 15.0
@export var spawn_seed: int = -1

var exclusion_zones: Array[Vector2] = []
var _sprites: Array[TextureRect] = []

func _ready() -> void:	
	if not _texture:
		push_warning("No texture defined for world background generator!")
		return
	_spawn_background()

func _spawn_background() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var sampling_rect = Rect2(Vector2.ZERO, screen_size)
	
	var _position_points = PoissonDiskSampling.generate_points(
		sampling_rect,
		min_distance,
		max_attempts,
		spawn_seed,
		exclusion_zones,
		exclusion_radius
	)
	
	for _position in _position_points:
		_create_background_sprite(_position)

func set_exclusion_zones(zones: Array[Vector2]) -> void:
	exclusion_zones = zones
	if is_inside_tree():
		_clear_background()
		_spawn_background()

func add_exclusion_zone(zone_position: Vector2) -> void:
	exclusion_zones.append(zone_position)
	if is_inside_tree():
		_clear_background()
		_spawn_background()

func _create_background_sprite(grass_position: Vector2) -> void:
	var _sprite = TextureRect.new()
	_sprite.texture = _texture
	_sprite.position = grass_position
	_sprite.size = Vector2(1, 1)
	_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Add some variation
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(grass_position)
	
	# Random scale
	var scale_factor = rng.randf_range(item_scale_range.x, item_scale_range.y)
	_sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Random rotation
	var _rotation_degrees = rng.randf_range(-item_rotation_range, item_rotation_range)
	_sprite.rotation_degrees = _rotation_degrees
	
	# Random color tint for variety
	var tint_variation = rng.randf_range(0.9, 1.1)
	_sprite.modulate = Color(tint_variation, tint_variation * 1.05, tint_variation * 0.95)
	
	# Set pivot to bottom center for natural rotation
	if _texture:
		_sprite.pivot_offset = Vector2(_texture.get_width() * 0.5, _texture.get_height())
	
	add_child(_sprite)
	_sprites.append(_sprite)

func _clear_background() -> void:
	for sprite in _sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	_sprites.clear()
