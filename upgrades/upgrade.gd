class_name Upgrade extends Resource

enum Id { DRILL_POWER_I, DRILL_POWER_II }
enum Category { DRILL, ENGINE }

@export var id: Id
@export var name: String
@export var category: Category
@export var cost: Dictionary[GatherableResource.Id, int]

func get_effective_name() -> String:
	return name if self in Upgrades.revealed else "?"
