class_name Hud extends Control

@onready var depth_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/Panel3/MarginContainer/VBoxContainer/DepthLabel
@onready var energy_pb: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/EnergyPanel/MarginContainer/VBoxContainer2/MarginContainer/EnergyPB
@onready var hull_pb: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/HullPanel/MarginContainer/VBoxContainer3/MarginContainer/HullPB
@onready var cargo_h_flow_container: HFlowContainer = $MarginContainer/HBoxContainer/VBoxContainer3/Panel3/MarginContainer2/VBoxContainer/CargoHFlowContainer

@export var icon_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.depth_changed.connect(_update_depth)
	Globals.battery_energy_changed.connect(_update_energy)
	Globals.hull_integrity_changed.connect(_update_hull)
	Globals.cargo_changed.connect(_cargo_changed)

func _update_depth(depth: int):
	depth_label.text = str(depth) + " m"

func _update_energy(current_level: float, capacity: float):
	energy_pb.value = current_level / capacity

func _update_hull(current_level: float, max_level: float):
	hull_pb.value = current_level / max_level

func _cargo_changed(resources: Array[GatherableResource]):
	for c in cargo_h_flow_container.get_children():
		cargo_h_flow_container.remove_child(c)
	for r in resources:
		var icon = icon_scene.instantiate() as Icon
		icon.update_icon(r.icon)
		cargo_h_flow_container.add_child(icon)
