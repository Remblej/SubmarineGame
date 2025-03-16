class_name MapGenerator extends Node

@export var cave_threshold: float = 0
@export var caves_noise: FastNoiseLite
@export var resource_noise: FastNoiseLite
@export var bounds_noise: FastNoiseLite
@export var bounds_fluctuation = 5.0

func generate(settings: MapGenerationSettings) -> MapData:
	var time_begin = Time.get_unix_time_from_system()
	var map_data = MapData.new()
	
	_generate_terrain(settings, map_data)
	var time_after_terrain = Time.get_unix_time_from_system()
	print("terrain generated in: " + str(time_after_terrain - time_begin))

	_generate_resources(settings, map_data)
	print("resources generated in: " + str(Time.get_unix_time_from_system() - time_after_terrain))

	return map_data

func _generate_terrain(settings: MapGenerationSettings, map_data: MapData):
	caves_noise.seed = randi()
	bounds_noise.seed = randi()
	var bounds_fluctuations_factors = _calc_bounds_fluctuation_factors(settings)
	for x in range(settings.total_area.position.x, settings.total_area.end.x):
		for y in range(settings.total_area.position.y, settings.total_area.end.y):
			var coords = Vector2i(x, y)
			if is_in_no_generation_zone(coords, settings):
				continue
			if _is_in_playable_area(coords, settings, bounds_fluctuations_factors):
				if caves_noise.get_noise_2d(x, y) <= cave_threshold:
					map_data.terrain.push_back(coords)
			elif not is_in_no_bounds_zone(coords, settings):
				map_data.boundary.push_back(coords)
	
func _generate_resources(settings: MapGenerationSettings, map_data: MapData):
	for r in Resources.all:
		_generate_resource(r, settings, map_data)

func _generate_resource(resource: GatherableResource, settings: MapGenerationSettings, map_data: MapData):
	var width = settings.playable_area.size.x
	@warning_ignore("integer_division")
	var half_width = width / 2
	var height = settings.playable_area.size.y
	resource_noise.seed = randi()
	var noise_values: Array[ValueEntry] = []
	for x in range(-half_width, half_width):
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
		if candidate.pos not in map_data.terrain:
			continue
		if _is_or_neighbours_resource(candidate.pos, map_data):
			continue
		map_data.resources[candidate.pos] = resource.id
		grow_cluster(resource, candidate.pos, map_data)
		cluster_count += 1

func _is_or_neighbours_resource(pos: Vector2i, map_data: MapData):
	for x in [pos.x - 1, pos.x, pos.x + 1]:
		for y in [pos.y - 1, pos.y, pos.y + 1]:
			if map_data.resources.has(Vector2i(x, y)):
				return true
	return false

func grow_cluster(resource: GatherableResource, center: Vector2i, map_data: MapData):
	var frontier = [center]
	var visited = [center]
	var cluster_size = 1
	var target_size = lerp(resource.min_cluster_size, resource.max_cluster_size, resource.cluster_size_probability.sample(randf()))
	var directions = [Vector2i(-1,0), Vector2i(1,0), Vector2i(0,-1), Vector2i(0,1)]

	while cluster_size < target_size and frontier.size() > 0:
		var current = frontier.pick_random()
		frontier.erase(current)
		for offset in directions:
			var neighbor = current + offset
			if neighbor in visited:
				continue
			visited.push_back(neighbor)
			# Check if there is terrain underneath
			if neighbor not in map_data.terrain:
				continue
			# Optional: add a probability check to make growth irregular
			if randf() < .6:
				map_data.resources[neighbor] = resource.id
				frontier.append(neighbor)
				cluster_size += 1


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
	var min_val = bounds.values().min()
	var max_val = bounds.values().max()
	for v in bounds.keys():
		var val = float(bounds[v])
		bounds[v] = (val - min_val) / (max_val - min_val)
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
	
class ValueEntry:
	var pos: Vector2i
	var value: float

class MapData:
	var terrain: Array[Vector2i] = []
	var boundary: Array[Vector2i] = []
	var resources: Dictionary[Vector2i, GatherableResource.Id] = {}
