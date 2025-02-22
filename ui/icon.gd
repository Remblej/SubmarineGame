class_name Icon extends Control

@onready var texture_rect: TextureRect = $Panel/TextureRect

var texture: Texture2D:
	set(value):
		texture = value
		update_ui()

func _ready() -> void:
	update_ui()

func update_ui():
	if texture_rect and texture:
		texture_rect.texture = texture
