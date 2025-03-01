extends Node

signal drill_hit(tile: RID, drill_damage: int)
signal tile_hit(resource: GatherableResource) # resource is nullable
signal tile_destroyed(resource: GatherableResource) # resource is nullable
signal resource_drilled(resource: GatherableResource)
signal depth_changed(depth: int)
signal max_depth_changed(max_depth: int)
signal hull_integrity_changed(current_level: float, max_level: float)
signal cargo_changed(resources: Array[GatherableResource])
signal battery_energy_changed(current_level: float, capacity: float)
signal battery_depleted
signal battery_fully_charged
signal velocity_changed(velocity: Vector2)
signal entered_base(player: Player)
signal exited_base(player: Player)
signal embark()
signal resource_researched(resource: GatherableResource)

var max_depth: int = 0

func _ready() -> void:
	depth_changed.connect(_on_depth_change)

func _on_depth_change(depth: int):
	if depth > max_depth:
		max_depth = depth
		max_depth_changed.emit(max_depth)
