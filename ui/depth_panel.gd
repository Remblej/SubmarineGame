extends VBoxContainer

@onready var depth_label: Label = $DepthLabel

func _ready() -> void:
	Globals.depth_changed.connect(_update_depth)

func _update_depth(depth: int):
	depth_label.text = str(depth) + " m"
