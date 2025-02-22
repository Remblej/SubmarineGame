extends HBoxContainer

@export var resource_button_scene: PackedScene

@onready var resource_buttons_v_box: VBoxContainer = %ResourceButtonsVBox
@onready var label: Label = $Panel2/Label

func _ready() -> void:
	for c in resource_buttons_v_box.get_children():
		c.queue_free()
		resource_buttons_v_box.remove_child(c)
	for r in Globals.all_resources.resources:
		var b = resource_button_scene.instantiate() as ResourceResearchButton
		b.resource = r
		b.pressed.connect(func(): resource_pressed(r))
		resource_buttons_v_box.add_child(b)
	resource_pressed(Globals.all_resources.resources[0])

func resource_pressed(resource: GatherableResource):
	for rb: ResourceResearchButton in resource_buttons_v_box.get_children():
		rb.selected = rb.resource == resource
	label.text = resource.name
