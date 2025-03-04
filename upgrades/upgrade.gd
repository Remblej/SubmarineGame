class_name Upgrade extends Resource

@export var id: Upgrades.Id
@export var name: String
@export var category: Upgrades.Category
@export var cost: Dictionary # [resource_id: int, amount: int]
