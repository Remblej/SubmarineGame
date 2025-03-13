extends Camera2D



@export var shake_noise: FastNoiseLite

var _shake_magnitude: float
var _shake_speed: float
var _shake_decay_rate: float # how much _shake_magnitude is reduced per second
var _noise_i = 0.0

func _ready() -> void:
	Globals.screen_shake.connect(_start_shake)
	Globals.tile_hit.connect(func(r: GatherableResource): _on_resource_hit(r, false))
	Globals.tile_destroyed.connect(func(r: GatherableResource): _on_resource_hit(r, true))
	shake_noise.seed = randi()

func _process(delta: float) -> void:
	_shake_magnitude = move_toward(_shake_magnitude, 0, _shake_decay_rate * delta)
	_noise_i += fmod(delta * _shake_speed, 1000)
	offset = _calc_offset()
	
func _on_resource_hit(resource: GatherableResource, destroyed: bool):
	var mag = 3
	var speed = 30
	var dur = .3
	if destroyed:
		mag *= 1.2
		dur *= 1.1
	if resource and destroyed:
		mag *= 1.3
		dur *= 1.2
	_start_shake(mag, speed, dur)
	
func _start_shake(magnitude: float, speed: float, duration: float):
	_shake_magnitude = magnitude
	_shake_speed = speed
	_shake_decay_rate = magnitude / duration

func _calc_offset() -> Vector2:
	return Vector2(
		shake_noise.get_noise_2d(1, _noise_i),
		shake_noise.get_noise_2d(1000, _noise_i)
	) * _shake_magnitude
