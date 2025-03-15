extends Node2D

@export var tile_break_vfx: PackedScene

@onready var terrain_tml: TileMapLayer = $TerrainTML
@onready var boundary_tml: TileMapLayer = $BoundaryTML
@onready var hidden_resources_tml: TileMapLayer = $HiddenResourcesTML
@onready var resources_tml: TileMapLayer = $ResourcesTML
@onready var map_spawner: MapSpawner = $MapSpawner

#var generation_thread: Thread = Thread.new()
var default_terrain_hit_points = 2 # todo based on depth / biome
var _tile_damage: Dictionary = {} # [Vector2i, int] # TODO clean to avoid memory leak
var _explored_tiles: Array[Vector2i] = []

func _ready() -> void:
	Globals.drill_hit.connect(_on_drill_hit)
	map_spawner.generated.connect(_on_map_generated)
	map_spawner.start_generation()

func _on_drill_hit(tile: RID, drill_damage: int):
	var coords = terrain_tml.get_coords_for_body_rid(tile)
	if terrain_tml.get_cell_source_id(coords) == -1:
		return
	var r = _resource_at(coords)
	_tile_damage[coords] = _tile_damage.get(coords, 0) + drill_damage
	Globals.tile_hit.emit(r)
	if _tile_damage[coords] >= _get_hit_points(coords):
		_tile_damage.erase(coords)
		terrain_tml.set_cells_terrain_connect([coords], 0, -1, true)
		Globals.tile_destroyed.emit(r)
		_reveal_resources_after_dig(coords)
		var vfx = tile_break_vfx.instantiate() as CPUParticles2D
		add_child(vfx)
		vfx.global_position = terrain_tml.to_global(terrain_tml.map_to_local(coords))
		vfx.emitting = true
		#_reveal_resources_at(terrain_tml.get_surrounding_cells(coords))
		if r:
			resources_tml.erase_cell(coords)
			Globals.resource_drilled.emit(r)

func _get_hit_points(coords: Vector2i) -> int:
	var r = _resource_at(coords)
	if r:
		return r.hit_points
	return default_terrain_hit_points

func _resource_at(coords: Vector2i) -> GatherableResource:
	var data = resources_tml.get_cell_tile_data(coords)
	if data:
		var r_id = data.get_custom_data("resource_id") as GatherableResource.Id
		if r_id != null:
			return Resources.by_id.get(r_id, null)
	return null
	
func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_regenerate"):
		map_spawner.start_generation()

func _on_map_generated():
	_explored_tiles.clear()
	_tile_damage.clear()
	_reveal_resources_after_dig(Vector2i.ZERO) ## reveal resources initially visible

func _reveal_resources_at(coords: Vector2i):
	var source_id = hidden_resources_tml.get_cell_source_id(coords)
	if source_id != -1:
		resources_tml.set_cell(coords, source_id, hidden_resources_tml.get_cell_atlas_coords(coords))
		hidden_resources_tml.erase_cell(coords)

func _is_next_to_edge(coords: Vector2i) -> bool:
	for c in terrain_tml.get_surrounding_cells(coords):
		if terrain_tml.get_cell_source_id(c) == -1:
			return true
	return false

func _reveal_resources_after_dig(dig_position: Vector2i):
	var queue = [dig_position]

	while queue.size() > 0:
		var current = queue.pop_back()
		
		if current.y < 0: ## below 0 there is no map - safeguard from indefinate search
			continue
		if current in _explored_tiles: ## don't backtrack
			continue
		if terrain_tml.get_cell_source_id(current) != -1: ## if we hit terrain, reveal and stop
			_reveal_resources_at(current)
			continue
		if boundary_tml.get_cell_source_id(current) != -1: ## if we hit bounds, stop propagation
			continue
		
		## Otherwise (we hit not explored, empty tile) - set as explored and flood further
		_explored_tiles.push_back(current)
		for offset in [Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, 0), Vector2i(1, -1), Vector2i(1, 1), Vector2i(0, -1), Vector2i(0, 1)]: # traverse in 8 directions
			queue.append(current + offset)
