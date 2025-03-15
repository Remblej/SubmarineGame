extends Button

@onready var label: Label = $VBoxContainer/Label

var upgrade: Upgrade:
	set(value):
		upgrade = value
		update_ui()

var selected = false:
	set(value):
		selected = value
		update_ui()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()

func update_ui():
	if upgrade:
		if label:
			label.text = upgrade.get_effective_name()
	modulate.v = 1 if selected else .5
	release_focus()  # Ensures hover states reset properly
	
