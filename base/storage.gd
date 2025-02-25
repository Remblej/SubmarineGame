class_name Storage extends Node

var resources: Dictionary = {} # [GatherableResource, int]

func _ready() -> void:
	Globals.entered_base.connect(_on_entered_base)
	
func _on_entered_base(player: Player):
	var res = player.cargo.pop_last()
	while res:
		resources[res] = resources.get(res, 0) + 1
		res = player.cargo.pop_last()
	print("Currently in storage:")
	for r in resources.keys():
		print(str(resources[r]) + " " + r.name)
