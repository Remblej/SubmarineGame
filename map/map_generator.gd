class_name MapGenerator extends Node

@export var cave_threshold: float = 0
@export var caves_noise: FastNoiseLite
@export var resource_noise: FastNoiseLite

func spawn_terrain(width: int, height: int, terrain_tml: TileMapLayer):
	caves_noise.seed = randi()
	for x in range(-width/2, width/2):
		for y in range(0, height):
			var coords = Vector2i(x, y)
			if caves_noise.get_noise_2d(x, y) <= cave_threshold:
				terrain_tml.set_cells_terrain_connect([coords], 0, 0, false)
			else:
				terrain_tml.erase_cell(coords)

func spawn_resources(width: int, height: int, terrain_tml: TileMapLayer, resource_tml: TileMapLayer):
	for r in Globals.all_resources.resources:
		_spawn_resource(r, width, height, terrain_tml, resource_tml)
		
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

class ValueEntry:
	var pos: Vector2i
	var value: float
