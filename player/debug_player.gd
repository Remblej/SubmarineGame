extends Node2D

@onready var camera: Camera2D = $Camera2D

var _enabled = false

func _process(delta: float) -> void:
	var speed = 10.0 / camera.zoom.x
	position += Input.get_vector("debug_left", "debug_right", "debug_up", "debug_bottom") * speed


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_zoom_in"):
		var zoom = camera.zoom.x + .1
		camera.zoom = Vector2(zoom, zoom)
	if event.is_action_pressed("debug_zoom_out"):
		var zoom = camera.zoom.x - .1
		camera.zoom = Vector2(zoom, zoom)
	if event.is_action_pressed("debug_btn"):
		_enabled = not _enabled
		var p = get_tree().get_first_node_in_group("player") as Player
		if _enabled:
			p.movement.control_enabled = false
			camera.make_current()
			visible = true
			set_process(true)
		else:
			p.movement.control_enabled = true
			p.camera.make_current()
			visible = false
			set_process(false)
