class_name Movement extends Node2D

var control_enabled = true ## if disabled, player inputs will be ignored
# Max forward speed
@export var forward_speed = 250.0 # px/s
var recoil = -150.0 # px/s backward
var turning_speed = TAU/2 # radians/s
var acceleration = .1 # between 0 and 1 (i.e. 0.25 it means it covers 75% of the remaining distance per second)
var angle_difference_for_max_turning_speed = TAU/8 # angle in radians; if difference between desired angle and actual one is more than this, than player will rotate at full speed
var minimum_turning_speed_percent = 0.1 # percent of max speed that player will be turning even if angle difference is low

var _current_forward_speed = 0.0 # px/s

func calculate_forward_velocity(delta: float) -> float:
	var target_speed = forward_speed if _is_accelerating() else 0.0
	_current_forward_speed = lerpf(_current_forward_speed, target_speed, 1 - acceleration ** delta)
	return _current_forward_speed

func calculate_rotation(old_rotation: float, delta: float) -> float:
	var rotation_difference = wrapf(_target_rotation() - old_rotation, -PI, PI)
	var multi = clampf(abs(rotation_difference) / angle_difference_for_max_turning_speed, minimum_turning_speed_percent, 1.0)
	var max_rotation_change = turning_speed * multi * delta
	var rotation_change = clampf(rotation_difference, -max_rotation_change, max_rotation_change)
	return old_rotation + rotation_change

func _is_accelerating() -> bool:
	return control_enabled and Input.is_action_pressed("Accelerate")

func _target_rotation() -> float:
	return (get_global_mouse_position() - global_position).angle()

func apply_recoil():
	_current_forward_speed = recoil
