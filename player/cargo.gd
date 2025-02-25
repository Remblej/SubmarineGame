class_name Cargo extends Node

@export var floating_text_scene: PackedScene

var capacity = 6
var _resources: Array[GatherableResource] = []

func _ready() -> void:
	Globals.resource_drilled.connect(_on_resource_drilled)

func _on_resource_drilled(resource: GatherableResource):
	if try_add(resource):
		_spawn_floating_text("+1 " + resource.name, resource.color)
	else:
		_spawn_floating_text("No cargo space!", Color.RED)

func _spawn_floating_text(text: String, color: Color):
	var t = floating_text_scene.instantiate() as FloatingText
	t.set_text(text, color)
	t.global_position = get_parent().global_position + Vector2.UP * 32
	get_tree().root.add_child(t)

func pop_last() -> GatherableResource:
	var r = _resources.pop_back()
	if r:
		Globals.cargo_changed.emit(_resources)
		return r
	return null

func try_add(resource: GatherableResource) -> bool:
	if _resources.size() < capacity:
		_resources.push_back(resource)
		Globals.cargo_changed.emit(_resources)
		return true
	return false

func try_remove(resource: GatherableResource) -> bool:
	if _resources.has(resource):
		_resources.erase(resource)
		Globals.cargo_changed.emit(_resources)
		return true
	return false
