class_name GatherableResource extends Resource

enum Id { GOLD, IRON, COPPER, DIAMOND }

@export var id: Id
@export var name: String
@export var hit_points: int
@export var color: Color
@export var icon: Texture2D
@export var hit_sfx: AudioStream
@export var destroy_sfx: AudioStream

@export var atlas_coords: Array[Vector2i]
@export var base_rarity: float = 1.0 # 0 - never spawns, 2 - spawns twice as baseline
@export var rarity_curve: Curve = Curve.new() # further modify rarity (x = as % of max depth, y = rarity)

@export var min_clusters: int
@export var max_clusters: int
@export var min_cluster_size: int
@export var max_cluster_size: int
@export var cluster_size_probability: Curve 

func get_effective_name() -> String:
	return name if self in Resources.researched else "?"
