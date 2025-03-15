extends Control

@onready var embark_button: Button = %EmbarkButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	Globals.game_state_changed.connect(func(_old, new): visible = new == Globals.GameState.MOTHERSHIP_UI)
	embark_button.pressed.connect(_on_embark_pressed)

func _on_embark_pressed():
	Globals.game_state = Globals.GameState.UNDOCKING
