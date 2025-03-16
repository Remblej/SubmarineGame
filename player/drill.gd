class_name Drill extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var damage = 1
var cooldown = .5 # s
var _can_hit = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_shape_entered.connect(_on_collision)
	timer.wait_time = cooldown
	timer.timeout.connect(_on_cooldown_end)


func _on_cooldown_end():
	set_deferred("monitoring", true)
	_can_hit = true
	
func _on_collision(body_rid, body, _body_shape_index, _local_shape_index):
	if body is not TileMapLayer or not _can_hit:
		return
	_can_hit = false
	set_deferred("monitoring", false)
	timer.start()
	Globals.drill_hit.emit(body_rid, damage)
