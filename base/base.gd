class_name Base extends Node2D

@onready var docking_area: Area2D = $DockingArea
@onready var docking_marker: Marker2D = $DockingMarker

func _ready() -> void:
	docking_area.body_entered.connect(_on_player_enter)
	Globals.embark.connect(_on_embark)
	
func _on_player_enter(body: Node2D):
	if body is Player:
		var p = body as Player
		Globals.entering_base.emit(p)
		# animate player docking
		var t1 = get_tree().create_tween().set_loops(1)
		t1.tween_property(p, "global_position", docking_marker.global_position, 2)
		var t2 = get_tree().create_tween().set_loops(1)
		t2.tween_property(p, "rotation_degrees", 0, 1)
		await t1.finished
		Globals.entered_base.emit(p)

func _on_embark():
	var p = get_tree().get_first_node_in_group("player")
	Globals.exiting_base.emit(p)
	# animate player undocking
	var t1 = get_tree().create_tween().set_loops(1)
	t1.tween_property(p, "position:y", 100, 2).as_relative()
	var t2 = get_tree().create_tween().set_loops(1)
	t2.tween_property(p, "rotation_degrees", 90, 1)
	await t1.finished
	Globals.exited_base.emit(p)
