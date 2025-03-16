extends Control

@onready var new_game_btn: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/NewGameBtn
@onready var options_btn: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/OptionsBtn
@onready var credits_btn: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/CreditsBtn
@onready var exit_btn: Button = $MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ExitBtn

func _ready() -> void:
	Globals.game_state_changed.connect(func(_old, new): visible = new == Globals.GameState.MAIN_MENU)
	new_game_btn.pressed.connect(_new_game)
	exit_btn.pressed.connect(func(): get_tree().quit())

func _new_game():
	Globals.game_state = Globals.GameState.CHOOSING_BIOME
