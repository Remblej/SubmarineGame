class_name Mothership extends Node2D

@export var speed = 50.0

@onready var docking_area: Area2D = $DockingArea
@onready var docking_marker: Marker2D = $DockingMarker
@onready var bubble_vfx: CPUParticles2D = $BubbleVfx
@onready var bubble_vfx_2: CPUParticles2D = $BubbleVfx2
@onready var bubble_vfx_3: CPUParticles2D = $BubbleVfx3

var _is_traveling = true

func _ready() -> void:
	docking_area.monitoring = false
	Globals.game_state_changed.connect(_on_game_state_change)
	docking_area.body_entered.connect(_on_player_enter)

func _physics_process(delta: float) -> void:
	if _is_traveling:
		position.x += speed * delta
		

func _on_game_state_change(_old: Globals.GameState, new: Globals.GameState):
	_is_traveling = new == Globals.GameState.MAIN_MENU
	_enable_bubble_vfx(_is_traveling)
	_enable_docking_area(new == Globals.GameState.PLAYING)
	if new == Globals.GameState.UNDOCKING:
		_undock_player()

func _on_player_enter(body: Node2D):
	if body is Player:
		var p = body as Player
		Globals.game_state = Globals.GameState.DOCKING
		# animate player docking
		var t1 = get_tree().create_tween().set_loops(1)
		t1.tween_property(p, "global_position", docking_marker.global_position, 2)
		var t2 = get_tree().create_tween().set_loops(1)
		t2.tween_property(p, "rotation_degrees", 0, 1)
		await t1.finished
		Globals.game_state = Globals.GameState.MOTHERSHIP_UI

func _undock_player():
	var p = get_tree().get_first_node_in_group("player")
	# animate player undocking
	var t1 = get_tree().create_tween().set_loops(1)
	t1.tween_property(p, "position:y", 100, 2).as_relative()
	var t2 = get_tree().create_tween().set_loops(1)
	t2.tween_property(p, "rotation_degrees", 90, 1)
	await t1.finished
	Globals.game_state = Globals.GameState.PLAYING

func _enable_docking_area(enable: bool):
	docking_area.monitoring = enable
	#docking_area.set_deferred("monitoring", enable)

func _enable_bubble_vfx(enable: bool):
	bubble_vfx.visible = enable
	bubble_vfx_2.visible = enable
	bubble_vfx_3.visible = enable
