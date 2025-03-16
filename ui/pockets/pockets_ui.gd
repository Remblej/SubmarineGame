extends Control

@export var number_of_options = 3
@export var pocket_button_scene: PackedScene

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	visible = false
	Globals.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(_old: Globals.GameState, new: Globals.GameState):
	if new == Globals.GameState.CHOOSING_POCKET:
		for c in h_box_container.get_children():
			c.queue_free()
			h_box_container.remove_child(c)
		for i in range(number_of_options):
			var btn = pocket_button_scene.instantiate() as PocketButton
			btn.pocket = Globals.current_biome.random_pocket()
			h_box_container.add_child(btn)
		visible = true
	else:
		visible = false
