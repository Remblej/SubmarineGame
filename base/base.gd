class_name Base extends Node2D

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_player_enter)
	area_2d.body_exited.connect(_on_player_exit)
	
func _on_player_enter(body: Node2D):
	if body is Player:
		Globals.entered_base.emit(body as Player)
	
func _on_player_exit(body: Node2D):
	if body is Player:
		Globals.exited_base.emit(body as Player)
