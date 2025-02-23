extends Node

signal drill_hit(tile: RID, drill_damage: int)
signal resource_drilled(resource: GatherableResource)
signal depth_changed(depth: int)
signal max_depth_changed(max_depth: int)
signal hull_integrity_changed(current_level: float, max_level: float)
signal cargo_changed(resources: Array[GatherableResource])
signal battery_energy_changed(current_level: float, capacity: float)
signal battery_depleted
signal battery_fully_charged
signal velocity_changed(velocity: Vector2)
signal entered_base
signal exited_base

@export var all_resources: GatherableResources
var resource_by_id: Dictionary # [resource_id: int, GatherableResource]
var max_depth: int = 0

func _ready() -> void:
	depth_changed.connect(_on_depth_change)
	for r in all_resources.resources:
		resource_by_id[r.id] = r

func _on_depth_change(depth: int):
	if depth > max_depth:
		max_depth = depth
		max_depth_changed.emit(max_depth)
