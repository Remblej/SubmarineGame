extends Node

@export var all: Array[Upgrade]
var by_id: Dictionary # [upgrade_id: int, Upgrade]
var revealed: Array[Upgrade] = []
var unlocked: Array[Upgrade] = []
