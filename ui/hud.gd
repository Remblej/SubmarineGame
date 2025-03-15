class_name Hud extends Control

func _ready() -> void:
	visible = false
	Globals.game_state_changed.connect(func(_old, new): visible = new == Globals.GameState.PLAYING)
