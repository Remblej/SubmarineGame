class_name Battery extends Node

var capacity: float = 100

var _is_charging = false
var _is_engine_used = false

var _current_level: float = capacity
var _engine_depletion_rate: float = .1 # /s
var _drill_hit_depletion: float = 1
var _charging_rate: float = 5 # /s

func _ready() -> void:
	Globals.drill_hit.connect(_on_drill_hit)
	Globals.velocity_changed.connect(_on_velocity_changed)
	Globals.game_state_changed.connect(func(_old, new): _is_charging = new == Globals.GameState.MOTHERSHIP_UI)

func _process(delta: float) -> void:
	var change = 0
	if _is_engine_used:
		change -= _engine_depletion_rate * delta
	if _is_charging:
		change += _charging_rate * delta
	_update_current_level(change)

func is_depleted() -> bool:
	return _current_level <= 0

func _on_velocity_changed(velocity: Vector2):
	_is_engine_used = velocity.length_squared() > 0

func _on_drill_hit(_tile: RID, _drill_damage: int):
	_update_current_level(-_drill_hit_depletion)

func _update_current_level(change):
	var new_level = _current_level + change
	if _current_level > 0 and new_level <= 0:
		Globals.battery_depleted.emit()
	elif _current_level < capacity and new_level >= capacity:
		Globals.battery_fully_charged.emit()
	_current_level = clamp(new_level, 0, capacity)
	Globals.battery_energy_changed.emit(_current_level, capacity)
