extends VBoxContainer

@onready var energy_pb: ProgressBar = $MarginContainer/EnergyPB

func _ready() -> void:
	Globals.battery_energy_changed.connect(_update_energy)

func _update_energy(current_level: float, capacity: float):
	energy_pb.value = current_level / capacity
