extends Node

signal drill_hit(tile: RID, drill_damage: int)
signal resource_drilled(resource: GatherableResource)
signal depth_changed(depth: int)
signal energy_changed(current_level: float, capacity: float)
signal hull_integrity_changed(current_level: float, max_level: float)
signal resource_added_to_cargo(resource: GatherableResource)
signal resource_removed_from_cargo(resource: GatherableResource)
