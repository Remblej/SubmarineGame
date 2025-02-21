class_name Cargo extends Node

@export var floating_text_scene: PackedScene

var capacity = 6
var resources: Array[GatherableResource] = []

func _ready() -> void:
	Globals.resource_drilled.connect(_on_resource_drilled)

func _on_resource_drilled(resource: GatherableResource):
	if resources.size() < capacity:
		resources.push_back(resource)
		Globals.cargo_changed.emit(resources)
		_spawn_floating_text("+1 " + resource.name, resource.color)
	else:
		_spawn_floating_text("No cargo space!", Color.RED)

func _spawn_floating_text(text: String, color: Color):
	var t = floating_text_scene.instantiate() as FloatingText
	t.set_text(text, color)
	t.global_position = get_parent().global_position
	get_tree().root.add_child(t)
