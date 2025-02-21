class_name Cargo extends Node

var capacity = 6
var resources: Array[GatherableResource] = []

func _ready() -> void:
	Globals.resource_drilled.connect(_on_resource_drilled)

func _on_resource_drilled(resource: GatherableResource):
	if resources.size() < capacity:
		resources.push_back(resource)
		Globals.cargo_changed.emit(resources)
