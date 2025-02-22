class_name ResourceResearchButton extends Button

@onready var label: Label = $VBoxContainer/Label
@onready var texture_rect: TextureRect = $VBoxContainer/Panel/TextureRect

var resource: GatherableResource:
	set(value):
		resource = value
		update_ui()

var selected = false:
	set(value):
		selected = value
		update_ui()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()

func update_ui():
	if resource:
		if label:
			label.text = resource.name
		if texture_rect:
			texture_rect.texture = resource.icon
	modulate.v = 1 if selected else .5
	release_focus()  # Ensures hover states reset properly
	
