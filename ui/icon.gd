class_name Icon extends Control

@onready var texture_rect: TextureRect = $Panel/TextureRect

var texture: Texture2D

func update_icon(texture: Texture2D):
	self.texture = texture
	if texture_rect:
		texture_rect.texture = texture

func _ready() -> void:
	texture_rect.texture = texture
