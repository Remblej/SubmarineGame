extends Node

signal drill_hit(tile: RID, drill_damage: int)
signal resource_drilled(resource: GatherableResource)
signal depth_changed(depth: int)
signal hull_integrity_changed(current_level: float, max_level: float)
signal resource_added_to_cargo(resource: GatherableResource)
signal resource_removed_from_cargo(resource: GatherableResource)
signal battery_energy_changed(current_level: float, capacity: float)
signal battery_depleted
signal battery_fully_charged
signal velocity_changed(velocity: Vector2)
