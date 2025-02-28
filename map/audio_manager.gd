extends Node2D

@export var default_hit_sfx: AudioStream
@export var default_destroy_sfx: AudioStream

@onready var hit_player: AudioStreamPlayer2D = $HitPlayer
@onready var resource_hit_player: AudioStreamPlayer2D = $ResourceHitPlayer
@onready var destroy_player: AudioStreamPlayer2D = $DestroyPlayer
@onready var resource_destroy_player: AudioStreamPlayer2D = $ResourceDestroyPlayer

func _ready() -> void:
	Globals.tile_hit.connect(_on_tile_hit)
	Globals.tile_destroyed.connect(_on_tile_destroyed)
	hit_player.stream = default_hit_sfx
	destroy_player.stream = default_destroy_sfx 

func _on_tile_hit(resource: GatherableResource):
	hit_player.pitch_scale = randf_range(.9, 1.1)
	hit_player.play()
	if resource and resource.hit_sfx:
		resource_hit_player.stream = resource.hit_sfx
		resource_hit_player.pitch_scale = randf_range(.97, 1.03)
		resource_hit_player.play()
	

func _on_tile_destroyed(resource: GatherableResource):
	destroy_player.play()
	if resource and resource.destroy_sfx:
		resource_destroy_player.stream = resource.destroy_sfx
		resource_destroy_player.play()
