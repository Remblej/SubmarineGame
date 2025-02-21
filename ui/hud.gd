class_name Hud extends Control

@onready var depth_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/Panel3/MarginContainer/VBoxContainer/DepthLabel
@onready var energy_pb: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/EnergyPanel/MarginContainer/VBoxContainer2/MarginContainer/EnergyPB
@onready var hull_pb: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/HullPanel/MarginContainer/VBoxContainer3/MarginContainer/HullPB

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.depth_changed.connect(_update_depth)
	Globals.battery_energy_changed.connect(_update_energy)
	Globals.hull_integrity_changed.connect(_update_hull)
	Globals.resource_added_to_cargo.connect(_resource_added_to_cargo)
	Globals.resource_removed_from_cargo.connect(_resource_removed_from_cargo)

func _update_depth(depth: int):
	depth_label.text = str(depth) + " m"

func _update_energy(current_level: float, capacity: float):
	energy_pb.value = current_level / capacity

func _update_hull(current_level: float, max_level: float):
	hull_pb.value = current_level / max_level

func _resource_added_to_cargo(resouece: GatherableResource):
	pass

func _resource_removed_from_cargo(resouece: GatherableResource):
	pass
