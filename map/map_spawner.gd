class_name MapSpawner extends Node

@export var bounds_padding = 16
@export var base_tunnel_width = 4
@export var async_tile_spawn_batch_size = 128
@export var terrain_tml: TileMapLayer
@export var boundary_tml: TileMapLayer
@export var hidden_resources_tml: TileMapLayer
@export var resources_tml: TileMapLayer

@onready var map_generator: MapGenerator = $MapGenerator

signal generated

var _state = State.IDLE
var _generator_thread: Thread
var _terrain_spawn_queue: Array[Vector2i] = []
var _boundary_spawn_queue: Array[Vector2i] = []
var _resources_spawn_queue: Dictionary[Vector2i, GatherableResource.Id] = {}

func start_generation():
	if _state != State.IDLE:
		printerr("Attempted to start map generation before previous one ended")
		return
	_state = State.GENERATING_MAP_DATA
	## Clean up
	terrain_tml.clear()
	boundary_tml.clear()
	resources_tml.clear()
	hidden_resources_tml.clear()
	## Start async generation
	_generator_thread = Thread.new()
	_generator_thread.start(_generate_map_data_threaded)

func _process(delta: float) -> void:
	## SPAWNING TERRAIN
	if _state == State.SPAWNING_TERRAIN:
		if _terrain_spawn_queue.is_empty():
			_state = State.SPAWNING_BOUNDARIES
		else:
			var batch = _terrain_spawn_queue.slice(0, async_tile_spawn_batch_size)
			_terrain_spawn_queue = _terrain_spawn_queue.slice(async_tile_spawn_batch_size)
			terrain_tml.set_cells_terrain_connect(batch, 0, 0, false)
	## SPAWNING BOUNDARIES
	elif _state == State.SPAWNING_BOUNDARIES:
		if _boundary_spawn_queue.is_empty():
			_state = State.SPAWNING_RESOURCES
		else:
			var batch = _boundary_spawn_queue.slice(0, async_tile_spawn_batch_size)
			_boundary_spawn_queue = _boundary_spawn_queue.slice(async_tile_spawn_batch_size)
			boundary_tml.set_cells_terrain_connect(batch, 0, 0, false)
	## SPAWNING_RESOURCES
	elif _state == State.SPAWNING_RESOURCES:
		for pos in _resources_spawn_queue.keys():
			var r = Resources.by_id[_resources_spawn_queue[pos]]
			var atlas_coords = r.atlas_coords.pick_random()
			hidden_resources_tml.set_cell(pos, 2, atlas_coords)
		_resources_spawn_queue.clear()
		_state = State.IDLE
		generated.emit()

func _generate_map_data_threaded():
	## Prep settings
	var width = Globals.current_pocket.random_width()
	var height = Globals.current_pocket.random_height()
	var settings = MapGenerator.MapGenerationSettings.new()
	settings.playable_area = Rect2i(0, 1, 0, 0).grow_individual(width/2, 0, width/2, height)
	settings.total_area = settings.playable_area.grow_individual(bounds_padding, 1, bounds_padding, bounds_padding)
	settings.no_generation_zones.push_back(Rect2i().grow_individual(base_tunnel_width / 2, 0, base_tunnel_width / 2, 4)) # small dug out area below base
	settings.no_bounds_zones.push_back(Rect2i().grow_individual(base_tunnel_width / 2, 0, base_tunnel_width / 2, height/2)) # make sure no bounds generate under base
	## Generate terrain data
	var data = map_generator.generate(settings)
	set_deferred("_terrain_spawn_queue", data.terrain)
	set_deferred("_boundary_spawn_queue", data.boundary)
	set_deferred("_resources_spawn_queue", data.resources)
	set_deferred("_state", State.SPAWNING_TERRAIN)

func _exit_tree():
	if _generator_thread and _generator_thread.is_started():
		_generator_thread.wait_to_finish()

enum State { IDLE, GENERATING_MAP_DATA, SPAWNING_TERRAIN, SPAWNING_BOUNDARIES, SPAWNING_RESOURCES }
