class_name Player extends CharacterBody2D

@onready var drill_sprite: Sprite2D = $DrillSprite
@onready var camera: Camera2D = $Camera2D
@onready var movement: Movement = $Movement
@onready var drill: Drill = $Drill
@onready var cargo: Cargo = $Cargo
@onready var hud: Hud = $CanvasLayer2/Hud
@onready var upgrades_panel: Control = $CanvasLayer2/UpgradesPanel

var _depth: int

func _ready() -> void:
	Globals.drill_hit.connect(_on_drill_hit)
	Globals.entering_base.connect(_on_entering_base)
	Globals.entered_base.connect(_on_entered_base)
	Globals.exiting_base.connect(_on_exiting_base)
	Globals.exited_base.connect(_on_exited_base)
	var drill_tween = get_tree().create_tween()
	drill_tween.set_loops()
	drill_tween.tween_property(drill_sprite, "offset:x", 10, .1)
	drill_tween.tween_property(drill_sprite, "offset:x", 0, .2)

func _process(delta: float) -> void:
	# depth
	var new_depth = round((global_position.y - 32) / 64)
	if _depth != new_depth:
		Globals.depth_changed.emit(new_depth)
	_depth = new_depth
	# drill animation
	drill_sprite.offset.x = sin(delta*100000) * 100

func _physics_process(delta: float) -> void:
	rotation = movement.calculate_rotation(rotation,delta)
	velocity = Vector2.RIGHT.rotated(rotation) * movement.calculate_forward_velocity(delta)
	Globals.velocity_changed.emit(velocity)
	move_and_slide()

func _on_drill_hit(tile: RID, drill_damage: int):
	movement.apply_recoil()
	
func _on_entering_base(player: Player):
	hud.visible = false
	movement.control_enabled = false

func _on_entered_base(player: Player):
	upgrades_panel.visible = true

func _on_exiting_base(player: Player):
	upgrades_panel.visible = false

func _on_exited_base(player: Player):
	hud.visible = true
	movement.control_enabled = true
