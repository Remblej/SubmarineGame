extends VBoxContainer

@onready var cargo_h_flow_container: HFlowContainer = $CargoHFlowContainer

@export var icon_scene: PackedScene

func _ready() -> void:
	Globals.cargo_changed.connect(_cargo_changed)

func _cargo_changed(resources: Array[GatherableResource]):
	for c in cargo_h_flow_container.get_children():
		cargo_h_flow_container.remove_child(c)
	for r in resources:
		var icon = icon_scene.instantiate() as Icon
		icon.texture = r.icon
		cargo_h_flow_container.add_child(icon)
