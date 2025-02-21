class_name Hull extends Node

var max_depth_without_damage = 20
var depth_damage_scaling: float = .5

var max_hull_integrity: float = 100
var _current_hull_integrity: float = max_hull_integrity
var _current_depth = 0

func _ready() -> void:
	Globals.depth_changed.connect(func(depth): _current_depth = depth)

func _process(delta: float) -> void:
	_current_hull_integrity -= _calc_hull_damage() * delta
	_current_hull_integrity = clamp(_current_hull_integrity, 0, max_hull_integrity)
	Globals.hull_integrity_changed.emit(_current_hull_integrity, max_hull_integrity)

func _calc_hull_damage():
	var d = (_current_depth - max_depth_without_damage) * depth_damage_scaling
	return max(d, 0)
