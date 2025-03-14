extends Node

@export var all: Array[GatherableResource]
var by_id: Dictionary[GatherableResource.Id, GatherableResource]
var seen: Array[GatherableResource]
var researched: Array[GatherableResource]

func _ready() -> void:
	for r in all:
		by_id[r.id] = r
	Globals.resource_drilled.connect(_on_resource_drilled)
	Globals.resource_researched.connect(_on_resource_researched)

func _on_resource_drilled(resource: GatherableResource):
	if resource not in seen:
		seen.push_back(resource)

func _on_resource_researched(resource: GatherableResource):
	if resource not in researched:
		researched.push_back(resource)
	
