extends HBoxContainer

@export var resource_button_scene: PackedScene

@onready var resource_buttons_v_box: VBoxContainer = %ResourceButtonsVBox
@onready var research_label: Label = $Panel2/VBoxContainer/ResearchLabel
@onready var research_button: Button = $Panel2/VBoxContainer/ResearchButton

var _current_resource: GatherableResource

func _ready() -> void:
	_refresh_ui()
	visibility_changed.connect(_refresh_ui)
	research_button.pressed.connect(_on_research_button_pressed)

func _refresh_ui():
	for c in resource_buttons_v_box.get_children():
		c.queue_free()
		resource_buttons_v_box.remove_child(c)
	for r in Resources.seen:
		var b = resource_button_scene.instantiate() as ResourceResearchButton
		b.resource = r
		b.pressed.connect(func(): resource_pressed(r))
		resource_buttons_v_box.add_child(b)
	if not _current_resource and Resources.seen.size() > 0:
		resource_pressed(Resources.seen[0])
	else:
		resource_pressed(_current_resource)

func resource_pressed(resource: GatherableResource):
	_current_resource = resource
	for rb: ResourceResearchButton in resource_buttons_v_box.get_children():
		rb.selected = rb.resource == _current_resource
	research_label.text = _current_resource.name if _current_resource in Resources.researched else "Unknown resource. Research it to learn about it."
	research_button.visible = _current_resource not in Resources.researched

func _on_research_button_pressed():
	Globals.resource_researched.emit(_current_resource)
	_refresh_ui()
