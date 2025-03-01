class_name Base extends Node2D

@onready var docking_area: Area2D = $DockingArea
@onready var outer_area: Area2D = $OuterArea

func _ready() -> void:
	docking_area.body_entered.connect(_on_player_enter)
	docking_area.body_exited.connect(_on_player_exit)
	outer_area.body_exited.connect(_on_player_exit_outer_area)
	Globals.embark.connect(_on_embark)
	
func _on_player_enter(body: Node2D):
	if body is Player:
		body.global_position = Vector2.UP * 64
		Globals.entered_base.emit(body as Player)

func _on_player_exit(body: Node2D):
	if body is Player:
		Globals.exited_base.emit(body as Player)

func _on_embark():
	docking_area.set_deferred("monitoring", false)

func _on_player_exit_outer_area(body: Node2D):
	if body is Player:
		docking_area.set_deferred("monitoring", true)
