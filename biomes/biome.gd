class_name Biome extends Resource

@export var name: String
@export var terrain_color: Color
@export var boundary_color: Color
@export var min_hardness: Pocket.Hardness
@export var max_hardness: Pocket.Hardness
@export var min_size: Pocket.Size
@export var max_size: Pocket.Size

func random_pocket() -> Pocket:
	var p = Pocket.new()
	p.size = randi_range(min_size, max_size)
	p.hardness = randi_range(min_hardness, max_hardness)
	return p
