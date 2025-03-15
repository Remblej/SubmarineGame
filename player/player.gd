class_name Player extends CharacterBody2D

@onready var drill_sprite: Sprite2D = $DrillSprite
@onready var camera: Camera2D = $Camera2D
@onready var movement: Movement = $Movement
@onready var drill: Drill = $Drill
@onready var cargo: Cargo = $Cargo
@onready var hud: Hud = $CanvasLayer2/Hud
@onready var mother_ship_ui: Control = $CanvasLayer2/MotherShipUI
@onready var bubble_vfx: CPUParticles2D = $BubbleVfx

var _states_for_bubble_vfx = [Globals.GameState.PLAYING, Globals.GameState.DOCKING, Globals.GameState.UNDOCKING]
var _depth: int
var _drill_tween: Tween

func _ready() -> void:
	Globals.tile_hit.connect(func (_resource: GatherableResource): movement.apply_recoil())
	_drill_tween = get_tree().create_tween()
	_drill_tween.set_loops()
	_drill_tween.tween_property(drill_sprite, "offset:x", 10, .1)
	_drill_tween.tween_property(drill_sprite, "offset:x", 0, .2)
	_drill_tween.pause()
	bubble_vfx.visible = false
	Globals.game_state_changed.connect(_on_game_state_changed)

func _process(delta: float) -> void:
	# depth
	var new_depth = round((global_position.y - 32) / 64)
	if _depth != new_depth:
		Globals.depth_changed.emit(new_depth)
	_depth = new_depth

func _physics_process(delta: float) -> void:
	rotation = movement.calculate_rotation(rotation,delta)
	velocity = Vector2.RIGHT.rotated(rotation) * movement.calculate_forward_velocity(delta)
	Globals.velocity_changed.emit(velocity)
	move_and_slide()

func _on_game_state_changed(old: Globals.GameState, new: Globals.GameState):
	bubble_vfx.visible = new in _states_for_bubble_vfx
	if new == Globals.GameState.PLAYING:
		_drill_tween.play()
	elif old == Globals.GameState.PLAYING:
		_drill_tween.pause()
		
