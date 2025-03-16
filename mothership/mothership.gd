class_name Mothership extends Node2D

@export var target_coasting_speed = 75.0
@export var traveling_alitutude = -64*6
@export var descening_distance_forward = 64*14
@export var descening_duration = 7

@onready var docking_area: Area2D = $DockingArea
@onready var docking_marker: Marker2D = $DockingMarker
@onready var bubble_vfx: CPUParticles2D = $BubbleVfx
@onready var bubble_vfx_2: CPUParticles2D = $BubbleVfx2
@onready var bubble_vfx_3: CPUParticles2D = $BubbleVfx3
@onready var flash_light: PointLight2D = $FlashLight
@onready var flash_light_2: PointLight2D = $FlashLight2

var _is_traveling = true
var _current_speed = target_coasting_speed
var _is_descending = false
var _is_ascending = false
var _flash_light_enabled = false:
	set(value):
		if _flash_light_enabled != value:
			_turn_flashlights(value)
		_flash_light_enabled = value
var _default_energy_fl_1: float
var _default_energy_fl_2: float

func _ready() -> void:
	docking_area.monitoring = false
	Globals.game_state_changed.connect(_on_game_state_change)
	Globals.embark.connect(func(): Globals.game_state = Globals.GameState.MOTHERSHIP_DESCENDING)
	docking_area.body_entered.connect(_on_player_enter)
	position.y = traveling_alitutude
	_default_energy_fl_1 = flash_light.energy
	_default_energy_fl_2 = flash_light_2.energy

func _physics_process(delta: float) -> void:
	if _is_traveling:
		position.x += _current_speed * delta

func _on_game_state_change(_old: Globals.GameState, new: Globals.GameState):
	_is_descending = new == Globals.GameState.MOTHERSHIP_DESCENDING
	_is_ascending = new == Globals.GameState.MOTHERSHIP_ASCENDING
	_enable_bubble_vfx(_is_traveling || _is_ascending || _is_descending)
	#_flash_light_enabled = _is_traveling || _is_ascending || _is_descending
	_enable_docking_area(new == Globals.GameState.PLAYING)
	if new == Globals.GameState.UNDOCKING:
		_undock_player()
	elif new == Globals.GameState.MOTHERSHIP_DESCENDING:
		var ts = get_tree().create_tween()
		ts.tween_property(self, "_current_speed", 200, 1).from(target_coasting_speed)
		await ts.finished
		_is_traveling = false

		var target_pos = Vector2(position.x + descening_distance_forward, 0)
		var tx = get_tree().create_tween()
		tx.tween_property(self, "position:x", target_pos.x, descening_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		var ty = get_tree().create_tween()
		ty.tween_property(self, "position:y", target_pos.y, descening_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		var tr = get_tree().create_tween()
		tr.tween_property(self, "rotation_degrees", 30, descening_duration/2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tr.tween_property(self, "rotation_degrees", 0, descening_duration/2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		Globals.mothership_starts_descend.emit(target_pos)
		await tx.finished
		Globals.game_state = Globals.GameState.UNDOCKING
	elif new == Globals.GameState.MOTHERSHIP_ASCENDING:
		var target_pos = Vector2(position.x + descening_distance_forward, traveling_alitutude)
		var tx = get_tree().create_tween()
		tx.tween_property(self, "position:x", target_pos.x, descening_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		var ty = get_tree().create_tween()
		ty.tween_property(self, "position:y", target_pos.y, descening_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		var tr = get_tree().create_tween()
		tr.tween_property(self, "rotation_degrees", -30, descening_duration/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tr.tween_property(self, "rotation_degrees", 0, descening_duration/2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tx.finished
		_is_traveling = true
		Globals.game_state = Globals.GameState.MOTHERSHIP_UI
		var ts = get_tree().create_tween()
		ts.tween_property(self, "_current_speed", target_coasting_speed, 1).from(200)
		

func _on_player_enter(body: Node2D):
	if body is Player:
		var p = body as Player
		Globals.game_state = Globals.GameState.DOCKING
		# animate player docking
		var t1 = get_tree().create_tween().set_loops(1)
		t1.tween_property(p, "global_position", docking_marker.global_position, 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		var t2 = get_tree().create_tween().set_loops(1)
		t2.tween_property(p, "rotation_degrees", 0, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		await t1.finished
		Globals.game_state = Globals.GameState.MOTHERSHIP_ASCENDING

func _undock_player():
	var p = get_tree().get_first_node_in_group("player")
	# animate player undocking
	var t1 = get_tree().create_tween().set_loops(1)
	t1.tween_property(p, "position:y", 100, 2).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var t2 = get_tree().create_tween().set_loops(1)
	t2.tween_property(p, "rotation_degrees", 90, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await t1.finished
	Globals.game_state = Globals.GameState.PLAYING

func _enable_docking_area(enable: bool):
	docking_area.monitoring = enable
	#docking_area.set_deferred("monitoring", enable)

func _enable_bubble_vfx(enable: bool):
	bubble_vfx.emitting = enable
	bubble_vfx_2.emitting = enable
	bubble_vfx_3.emitting = enable

func _turn_flashlights(on: bool):
	_turn_flashlight(flash_light, on, _default_energy_fl_1)
	_turn_flashlight(flash_light_2,  on, _default_energy_fl_2)

func _turn_flashlight(light: Light2D, on: bool, default_energy: float):
	var t = get_tree().create_tween()
	var target_energy = default_energy if on else 0.0
	t.tween_property(light, "energy", target_energy, .2)
