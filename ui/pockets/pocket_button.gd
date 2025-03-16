class_name PocketButton extends Button

@onready var size_label: Label = $VBoxContainer/HBoxContainer/SizeLabel
@onready var hardness_label: Label = $VBoxContainer/HBoxContainer2/HardnessLabel
@onready var resources_label: Label = $VBoxContainer/HBoxContainer3/ResourcesLabel

var pocket: Pocket:
	set(value):
		pocket = value
		if is_node_ready():
			_refresh_ui()

func _ready() -> void:
	pressed.connect(_on_pressed)
	if pocket:
		_refresh_ui()

func _refresh_ui():
	size_label.text = _size_text(pocket.size)
	hardness_label.text = _hardness_text(pocket.hardness)
	#resources_label.text = 

func _on_pressed():
	Globals.current_pocket = pocket
	Globals.game_state = Globals.GameState.MOTHERSHIP_UI

func _size_text(size: Pocket.Size) -> String:
	match size:
		Pocket.Size.VERY_SMALL: 
			return "Very Small"
		Pocket.Size.SMALL: 
			return "Small"
		Pocket.Size.MEDIUM: 
			return "Medium"
		Pocket.Size.BIG: 
			return "Big"
		Pocket.Size.VERY_BIG: 
			return "Very Big"
		_:
			return ""
		

func _hardness_text(hardness: Pocket.Hardness) -> String:
	match hardness:
		Pocket.Hardness.VERY_SOFT: 
			return "Very Soft"
		Pocket.Hardness.SOFT: 
			return "Soft"
		Pocket.Hardness.MEDIUM: 
			return "Medium"
		Pocket.Hardness.HARD: 
			return "Hard"
		Pocket.Hardness.VERY_HARD: 
			return "Very Hard"
		_:
			return ""
