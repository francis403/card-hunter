extends RefCounted
class_name PoissonDiskSampling

## Bridson's Fast Poisson Disk Sampling algorithm implementation
## Generates evenly distributed points with minimum distance constraints

static func generate_points(
	rect: Rect2,
	min_distance: float,
	max_attempts: int = 30,
	seed_value: int = -1,
	exclusion_zones: Array[Vector2] = [],
	exclusion_radius: float = 0.0
) -> Array[Vector2]:
	if seed_value != -1:
		RandomNumberGenerator.new().seed = seed_value
	
	var rng = RandomNumberGenerator.new()
	if seed_value != -1:
		rng.seed = seed_value
	
	var cell_size: float = min_distance / sqrt(2.0)
	var grid_width: int = int(ceil(rect.size.x / cell_size))
	var grid_height: int = int(ceil(rect.size.y / cell_size))
	
	# Grid to track occupied cells (-1 = empty, index = point index)
	var grid: Array[int] = []
	grid.resize(grid_width * grid_height)
	grid.fill(-1)
	
	var points: Array[Vector2] = []
	var active_list: Array[int] = []
	
	# Generate initial point (keep trying until we find one outside exclusion zones)
	var initial_point: Vector2
	var initial_attempts = 0
	while initial_attempts < 100:  # Prevent infinite loop
		initial_point = Vector2(
			rng.randf_range(rect.position.x, rect.position.x + rect.size.x),
			rng.randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		if _is_point_outside_exclusion_zones(initial_point, exclusion_zones, exclusion_radius):
			break
		initial_attempts += 1
	
	# If we couldn't find a valid initial point, return empty array
	if initial_attempts >= 100:
		print("PoissonDiskSampling: Could not find valid initial point after 100 attempts")
		return []
	
	var initial_index = points.size()
	points.append(initial_point)
	active_list.append(initial_index)
	
	var grid_pos = _world_to_grid(initial_point, rect.position, cell_size)
	if _is_valid_grid_pos(grid_pos, grid_width, grid_height):
		grid[grid_pos.y * grid_width + grid_pos.x] = initial_index
	
	# Main sampling loop
	while active_list.size() > 0:
		var random_index = rng.randi_range(0, active_list.size() - 1)
		var point_index = active_list[random_index]
		var point = points[point_index]
		
		var found_valid_point = false
		
		# Try to generate a new point around this active point
		for attempt in max_attempts:
			var angle = rng.randf() * TAU
			var distance = rng.randf_range(min_distance, 2.0 * min_distance)
			var candidate = point + Vector2(cos(angle), sin(angle)) * distance
			
			# Check if candidate is within bounds
			if not rect.has_point(candidate):
				continue
			
			# Check if candidate is outside exclusion zones
			if not _is_point_outside_exclusion_zones(candidate, exclusion_zones, exclusion_radius):
				continue
			
			# Check if candidate is valid (not too close to existing points)
			if _is_point_valid(candidate, rect.position, cell_size, grid, grid_width, grid_height, points, min_distance):
				var new_index = points.size()
				points.append(candidate)
				active_list.append(new_index)
				
				var candidate_grid_pos = _world_to_grid(candidate, rect.position, cell_size)
				if _is_valid_grid_pos(candidate_grid_pos, grid_width, grid_height):
					grid[candidate_grid_pos.y * grid_width + candidate_grid_pos.x] = new_index
				
				found_valid_point = true
				break
		
		# Remove point from active list if no valid candidates found
		if not found_valid_point:
			active_list.remove_at(random_index)
	
	return points

static func _world_to_grid(world_pos: Vector2, rect_origin: Vector2, cell_size: float) -> Vector2i:
	var relative_pos = world_pos - rect_origin
	return Vector2i(int(relative_pos.x / cell_size), int(relative_pos.y / cell_size))

static func _is_valid_grid_pos(grid_pos: Vector2i, grid_width: int, grid_height: int) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_width and grid_pos.y >= 0 and grid_pos.y < grid_height

static func _is_point_valid(
	candidate: Vector2,
	rect_origin: Vector2,
	cell_size: float,
	grid: Array[int],
	grid_width: int,
	grid_height: int,
	points: Array[Vector2],
	min_distance: float
) -> bool:
	var grid_pos = _world_to_grid(candidate, rect_origin, cell_size)
	
	# Check neighborhood cells
	var search_radius = int(ceil(min_distance / cell_size))
	for dy in range(-search_radius, search_radius + 1):
		for dx in range(-search_radius, search_radius + 1):
			var check_pos = Vector2i(grid_pos.x + dx, grid_pos.y + dy)
			
			if not _is_valid_grid_pos(check_pos, grid_width, grid_height):
				continue
			
			var point_index = grid[check_pos.y * grid_width + check_pos.x]
			if point_index != -1:
				var existing_point = points[point_index]
				if candidate.distance_to(existing_point) < min_distance:
					return false
	
	return true

static func _is_point_outside_exclusion_zones(
	point: Vector2,
	exclusion_zones: Array[Vector2],
	exclusion_radius: float
) -> bool:
	if exclusion_radius <= 0.0 or exclusion_zones.is_empty():
		return true
	
	for zone_center in exclusion_zones:
		if point.distance_to(zone_center) < exclusion_radius:
			return false
	
	return true
