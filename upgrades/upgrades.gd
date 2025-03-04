extends Node

enum Id { DRILL_POWER_I, DRILL_POWER_II }
enum Category { DRILL, ENGINE }

@export var all: Array[Upgrade]
var by_id: Dictionary # [upgrade_id: int, Upgrade]
var revealed: Array[Upgrade] = []
var unlocked: Array[Upgrade] = []
