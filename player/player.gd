class_name Player extends CharacterBody2D

@onready var movement: Movement = $Movement
@onready var drill: Drill = $Drill
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cargo: Cargo = $Cargo

var _depth: int

func _ready() -> void:
	Globals.drill_hit.connect(_on_drill_hit)

func _process(delta: float) -> void:
	var new_depth = round((global_position.y - 32) / 64)
	if _depth != new_depth:
		Globals.depth_changed.emit(new_depth)
	_depth = new_depth
	Globals.hull_integrity_changed.emit(.8, 1.0) # TODO

func _physics_process(delta: float) -> void:
	rotation = movement.calculate_rotation(rotation,delta)
	velocity = Vector2.RIGHT.rotated(rotation) * movement.calculate_forward_velocity(delta)
	Globals.velocity_changed.emit(velocity)
	move_and_slide()

func _on_drill_hit(tile: RID, drill_damage: int):
	movement.apply_recoil()
