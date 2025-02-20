class_name Player extends CharacterBody2D

@onready var movement: Movement = $Movement
@onready var drill: Drill = $Drill
@onready var resource_storage: ResourceStorage = $ResourceStorage

func _ready() -> void:
	Events.drill_hit.connect(_on_drill_hit)
	Events.resource_drilled.connect(_on_resource_drilled)

func _physics_process(delta: float) -> void:
	rotation = movement.calculate_rotation(rotation,delta)
	velocity = Vector2.RIGHT.rotated(rotation) * movement.calculate_forward_velocity(delta)
	move_and_slide()
	#print("depth: " + str(round(global_position.y / 64)))

func _on_drill_hit(tile: RID, drill_damage: int):
	movement.apply_recoil()

func _on_resource_drilled(resource: GatherableResource):
	resource_storage.add(resource.id)
	print(resource.name + " +1 -> " + str(resource_storage.amount(resource.id)))
