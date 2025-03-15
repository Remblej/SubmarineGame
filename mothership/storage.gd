class_name Storage extends Node

var resources: Dictionary = {} # [GatherableResource, int]

func _ready() -> void:
	Globals.game_state_changed.connect(func(_old, new): if new == Globals.GameState.MOTHERSHIP_UI: _on_entered_base())

func _on_entered_base():
	var player = get_tree().get_first_node_in_group("player")
	var res = player.cargo.pop_last()
	while res:
		resources[res] = resources.get(res, 0) + 1
		res = player.cargo.pop_last()
	print("Currently in storage:")
	for r in resources.keys():
		print(str(resources[r]) + " " + r.name)
