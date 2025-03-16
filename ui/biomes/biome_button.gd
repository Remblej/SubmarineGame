class_name BiomeButton extends Button

@onready var biome_name_label: Label = %BiomeNameLabel

var biome: Biome:
	set(value):
		biome = value
		if is_node_ready():
			_refresh_ui()

func _ready() -> void:
	pressed.connect(_on_pressed)
	if biome:
		_refresh_ui()

func _refresh_ui():
	biome_name_label.text = biome.name
	biome_name_label.modulate = biome.terrain_color
	self.self_modulate = biome.boundary_color

func _on_pressed():
	Globals.current_biome = biome
	Globals.game_state = Globals.GameState.CHOOSING_POCKET
