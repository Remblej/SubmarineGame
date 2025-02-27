class_name MapGenerator extends Node

@export var cave_threshold: float = 0
@export var caves_noise: FastNoiseLite
@export var resource_noise: FastNoiseLite
@export var bounds_noise: FastNoiseLite
@export var bounds_fluctuation = 5.0

class ValueEntry:
	var pos: Vector2i
	var value: float

func spawn_terrain(settings: MapGenerationSettings, terrain_tml: TileMapLayer, boundary_tml: TileMapLayer):
	var time = Time.get_unix_time_from_system()
	caves_noise.seed = randi()
	bounds_noise.seed = randi()
	var bounds_fluctuations_factors = _calc_bounds_fluctuation_factors(settings)
	var terrain_coords = []
	var boundary_cords = []
	
	for x in range(settings.total_area.position.x, settings.total_area.end.x):
		for y in range(settings.total_area.position.y, settings.total_area.end.y):
			var coords = Vector2i(x, y)
			if is_in_no_generation_zone(coords, settings):
				continue
			if _is_in_playable_area(coords, settings, bounds_fluctuations_factors):
				if caves_noise.get_noise_2d(x, y) <= cave_threshold:
					terrain_coords.push_back(coords)
			elif not is_in_no_bounds_zone(coords, settings):
				boundary_cords.push_back(coords)
	terrain_tml.set_cells_terrain_connect(terrain_coords, 0, 0, false)
	boundary_tml.set_cells_terrain_connect(boundary_cords, 0, 0, false)

	print("terrain generated in: " + str(Time.get_unix_time_from_system() - time))

func spawn_resources(width: int, height: int, terrain_tml: TileMapLayer, resource_tml: TileMapLayer):
	var time = Time.get_unix_time_from_system()
	for r in Globals.all_resources.resources:
		_spawn_resource(r, width, height, terrain_tml, resource_tml)
	print("resources generated in: " + str(Time.get_unix_time_from_system() - time))
		
func _spawn_resource(resource: GatherableResource, width: int, height: int, terrain_tml: TileMapLayer, resource_tml: TileMapLayer):
	resource_noise.seed = randi()
	var noise_values: Array[ValueEntry] = []
	for x in range(-width/2, width/2):
		for y in range(0, height):
			var entry = ValueEntry.new()
			entry.pos = Vector2i(x, y)
			entry.value = resource_noise.get_noise_2d(x, y)
			noise_values.push_back(entry)
	noise_values.sort_custom(func(a, b): return a.value > b.value) # desc

	var cluster_count = 0
	var desired_cluster_count = randi_range(resource.min_clusters, resource.max_clusters)
	while cluster_count < desired_cluster_count and noise_values.size() > 0:
		var candidate = noise_values.pop_back() # take position with highest value
		# Check if there is terrain underneath
		if terrain_tml.get_cell_source_id(candidate.pos) == -1:
			continue
		if _is_or_neighbours_resource(candidate.pos, resource_tml):
			continue
		_set_resource_tile(resource, candidate.pos, resource_tml)
		grow_cluster(resource, candidate.pos, terrain_tml, resource_tml)
		cluster_count += 1

func _is_or_neighbours_resource(pos: Vector2i, tml: TileMapLayer):
	for x in [pos.x - 1, pos.x, pos.x + 1]:
		for y in [pos.y - 1, pos.y, pos.y + 1]:
			if tml.get_cell_source_id(Vector2i(x, y)) != -1:
				return true
	return false

func grow_cluster(resource: GatherableResource, center: Vector2i, terrain_tml: TileMapLayer, resource_tml: TileMapLayer):
	var frontier = [center]
	var visited = [center]
	var cluster_size = 1
	var target_size = lerp(resource.min_cluster_size, resource.max_cluster_size, resource.cluster_size_probability.sample(randf()))
	var directions = [Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(0,1)]
	directions.shuffle()

	while cluster_size < target_size and frontier.size() > 0:
		var current = frontier.pop_back()
		for offset in directions:
			var neighbor = current + offset
			if neighbor in visited:
				continue
			visited.push_back(neighbor)
			# Check if there is terrain underneath
			if terrain_tml.get_cell_source_id(neighbor) == -1:
				continue
			# Optional: add a probability check to make growth irregular
			if randf() < .8:
				_set_resource_tile(resource, neighbor, resource_tml)
				frontier.append(neighbor)
				cluster_size += 1

func _set_resource_tile(resource: GatherableResource, coords: Vector2i, resource_tml: TileMapLayer):
	var atlas_coords = resource.atlas_coords.pick_random()
	resource_tml.set_cell(coords, 2, atlas_coords)

func is_in_no_generation_zone(coords: Vector2i, settings: MapGenerationSettings) -> bool:
	for no_zone in settings.no_generation_zones:
		if no_zone.has_point(coords):
			return true
	return false

func is_in_no_bounds_zone(coords: Vector2i, settings: MapGenerationSettings) -> bool:
	for no_zone in settings.no_bounds_zones:
		if no_zone.has_point(coords):
			return true
	return false
	
func _is_in_playable_area(coords: Vector2i, settings: MapGenerationSettings, bounds_fluctuations_factors: Dictionary) -> bool:
	if not settings.playable_area.has_point(coords): # out of playable area
		return false
	if is_in_no_bounds_zone(coords, settings): # if in no bounds area, ignore bounds calculation below
		return true
	return _distance_to_playable_edge(coords, settings) >= _get_bound_fluctuations_factor(coords, bounds_fluctuations_factors) * bounds_fluctuation

func _distance_to_playable_edge(coords: Vector2i, settings: MapGenerationSettings) -> int:
	var distance_to_left = abs(coords.x - settings.playable_area.position.x)
	var distance_to_right = abs(coords.x - (settings.playable_area.end.x - 1))
	var distance_to_top = abs(coords.y - settings.playable_area.position.y)
	var distance_to_bottom = abs(coords.y - (settings.playable_area.end.y - 1))
	return min(distance_to_left, distance_to_right, distance_to_top, distance_to_bottom)

func _calc_bounds_fluctuation_factors(settings: MapGenerationSettings) -> Dictionary:
	var bounds = {} ## Dictionary[Vector2i, int]
	for x in range(settings.playable_area.position.x, settings.playable_area.end.x + 1):
		for y in [settings.playable_area.position.y, settings.playable_area.end.y + 1]:
			bounds[Vector2i(x, y)] = bounds_noise.get_noise_2d(x+1000, y+1000)
	for x in [settings.playable_area.position.x, settings.playable_area.end.x + 1]:
		for y in range(settings.playable_area.position.y, settings.playable_area.end.y + 1):
			bounds[Vector2i(x, y)] = bounds_noise.get_noise_2d(x+1000, y+1000)
	var min = bounds.values().min()
	var max = bounds.values().max()
	for v in bounds.keys():
		var val = float(bounds[v])
		bounds[v] = (val - min) / (max - min)
	return bounds

func _get_bound_fluctuations_factor(coords: Vector2i, bounds_fluctuations_factors: Dictionary) -> float:
	var closest
	var smallest_distance = INF
	for v in bounds_fluctuations_factors.keys():
		var distance = (coords - v).length_squared()
		if distance < smallest_distance:
			smallest_distance = distance
			closest = v
	return bounds_fluctuations_factors[closest]

class MapGenerationSettings:
	var total_area: Rect2i ## area including playable area and margin around it
	var playable_area: Rect2i ## playble area can spawn destructive tiles and resources
	var no_generation_zones: Array[Rect2i] = [] ## zones in which nothing will be generated
	var no_bounds_zones: Array[Rect2i] = [] ## zones in which bounds will not be spawned
	
