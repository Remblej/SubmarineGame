extends VBoxContainer

@onready var depth_label: Label = $DepthLabel

func _ready() -> void:
	Globals.max_depth_changed.connect(_update_depth)
	_update_depth(Globals.max_depth)

func _update_depth(depth: int):
	depth_label.text = str(depth) + " m"
