class_name Player extends CharacterBody2D

@onready var movement: Movement = $Movement
@onready var drill: Drill = $Drill

func _ready() -> void:
	drill.drill_hit.connect(_on_drill_hit)

func _physics_process(delta: float) -> void:
	rotation = movement.calculate_rotation(rotation,delta)
	velocity = Vector2.RIGHT.rotated(rotation) * movement.calculate_forward_velocity(delta)
	move_and_slide()

func _on_drill_hit():
	movement.apply_recoil()
