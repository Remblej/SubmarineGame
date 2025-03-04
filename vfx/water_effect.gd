extends ColorRect

var texture_size: Vector2

func _ready() -> void:
	texture_size = (material.get("shader_parameter/fast_noise") as Texture2D).get_size()

func _process(_delta: float) -> void:
	var center := get_viewport().get_camera_2d().get_screen_center_position()
	material.set("shader_parameter/scale", size / texture_size)
	material.set("shader_parameter/displacement", center / texture_size)
