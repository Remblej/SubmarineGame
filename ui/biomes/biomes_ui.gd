extends Control

@export var biome_button_scene: PackedScene

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	visible = false
	Globals.game_state_changed.connect(func(_old, new): visible = new == Globals.GameState.CHOOSING_BIOME)
	for b in Biomes.all:
		var btn = biome_button_scene.instantiate() as BiomeButton
		btn.biome = b
		h_box_container.add_child(btn)
