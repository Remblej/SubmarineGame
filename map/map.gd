extends Node2D

@export var width = 64
@export var height = 64

@onready var background_tml: TileMapLayer = $BackgroundTML
@onready var terrain_tml: TileMapLayer = $TerrainTML
@onready var hidden_resources_tml: TileMapLayer = $HiddenResourcesTML
@onready var resources_tml: TileMapLayer = $ResourcesTML
@onready var map_generator: MapGenerator = $MapGenerator

var default_terrain_hit_points = 2 # todo based on depth / biome
var resource_hit_points: Dictionary = {} # [resource_id: int, hit_points: int]
var _tile_damage: Dictionary = {} # [Vector2i, int] # TODO clean to avoid memory leak

func _ready() -> void:
	Globals.drill_hit.connect(_on_drill_hit)
	generate()

func _on_drill_hit(tile: RID, drill_damage: int):
	var coords = terrain_tml.get_coords_for_body_rid(tile)
	var r = _resource_at(coords)
	_tile_damage[coords] = _tile_damage.get(coords, 0) + drill_damage
	Globals.tile_hit.emit(r)
	if _tile_damage[coords] >= _get_hit_points(coords):
		terrain_tml.set_cells_terrain_connect([coords], 0, -1, true)
		Globals.tile_destroyed.emit(r)
		_reveal_resources_at(terrain_tml.get_surrounding_cells(coords))
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
		var r_id = data.get_custom_data("resource_id") as int
		if r_id:
			return Globals.resource_by_id.get(r_id, null)
	return null
	
func generate():
	terrain_tml.clear()
	resources_tml.clear()
	hidden_resources_tml.clear()
	map_generator.spawn_terrain(width, height, terrain_tml)
	map_generator.spawn_resources(width, height, terrain_tml, hidden_resources_tml)
	_reveal_resources_initially()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_btn"):
		generate()

func _reveal_resources_initially():
	for x in range(-width/2, width/2):
		for y in range(0, height):
			var coords = Vector2i(x, y)
			var source_id = hidden_resources_tml.get_cell_source_id(coords)
			if source_id != -1 and _is_next_to_edge(coords):
				_reveal_resources_at([coords])

func _reveal_resources_at(coords: Array[Vector2i]):
	for c in coords:
		var source_id = hidden_resources_tml.get_cell_source_id(c)
		if source_id != -1:
			resources_tml.set_cell(c, source_id, hidden_resources_tml.get_cell_atlas_coords(c))
			hidden_resources_tml.erase_cell(c)

func _is_next_to_edge(coords: Vector2i) -> bool:
	for c in terrain_tml.get_surrounding_cells(coords):
		if terrain_tml.get_cell_source_id(c) == -1:
			return true
	return false
