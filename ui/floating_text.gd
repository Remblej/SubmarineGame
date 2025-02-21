class_name FloatingText extends Control

@onready var timer: Timer = $Timer
@onready var label: Label = $Label

var ttl = 2.0 # s
var velocity = Vector2.UP * 10 # px/s
var _text: String
var _color: Color = Color.BLACK

func set_text(text: String, color: Color = Color.BLACK):
	_text = text
	_color = color
	if label:
		label.text = _text
		label.modulate = _color

func _ready() -> void:
	label.text = _text
	label.modulate = _color
	timer.timeout.connect(func(): queue_free())
	timer.wait_time = ttl
	timer.start()

func _process(delta: float) -> void:
	global_position += velocity * delta
