class_name Drill extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

signal drill_hit

var cooldown = .5 # s
var _can_hit = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_shape_entered.connect(_on_collision)
	timer.wait_time = cooldown
	timer.timeout.connect(_on_cooldown_end)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_cooldown_end():
	set_deferred("monitoring", true)
	_can_hit = true
	
func _on_collision(body_rid, body, body_shape_index, local_shape_index):
	if body is not TileMapLayer or not _can_hit:
		return

	var tilemap = body as TileMapLayer
	var coords = tilemap.get_coords_for_body_rid(body_rid)
	#tilemap.erase_cell(coords)
	tilemap.set_cells_terrain_connect([coords], 0, -1, true)
	
	
	_can_hit = false
	set_deferred("monitoring", false)
	timer.start()
	drill_hit.emit()
