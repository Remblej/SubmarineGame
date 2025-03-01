extends Control

@onready var embark_button: Button = %EmbarkButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	embark_button.pressed.connect(_on_embark_pressed)

func _on_embark_pressed():
	Globals.embark.emit()
