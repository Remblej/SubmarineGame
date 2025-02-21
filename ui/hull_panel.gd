extends VBoxContainer

@onready var hull_pb: ProgressBar = $MarginContainer/HullPB

func _ready() -> void:
	Globals.hull_integrity_changed.connect(_update_hull)

func _update_hull(current_level: float, max_level: float):
	hull_pb.value = current_level / max_level
