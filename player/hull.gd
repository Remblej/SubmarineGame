class_name Hull extends Node

var max_depth_without_damage = 20
var depth_damage_scaling: float = .5
var repairing_rate: float = 3 # /s

var max_hull_integrity: float = 100
var _current_hull_integrity: float = max_hull_integrity
var _current_depth = 0
var _is_repairing = false

func _ready() -> void:
	Globals.game_state_changed.connect(func(_old, new): _is_repairing = new == Globals.GameState.MOTHERSHIP_UI)
	Globals.depth_changed.connect(func(depth): _current_depth = depth)

func _process(delta: float) -> void:
	_current_hull_integrity += (_calc_hull_repair() - _calc_hull_damage()) * delta
	_current_hull_integrity = clamp(_current_hull_integrity, 0, max_hull_integrity)
	Globals.hull_integrity_changed.emit(_current_hull_integrity, max_hull_integrity)
	
func _calc_hull_damage():
	var d = (_current_depth - max_depth_without_damage) * depth_damage_scaling
	return max(d, 0)

func _calc_hull_repair():
	return repairing_rate if _is_repairing else 0
