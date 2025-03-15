extends HBoxContainer

@export var upgrade_category_button_scene: PackedScene

@onready var categories_buttons_v_box: VBoxContainer = %CategoriesButtonsVBox
@onready var label: Label = $Panel2/VBoxContainer/Label

var _current_category: Upgrade.Category

func _ready() -> void:
	_refresh_ui()
	visibility_changed.connect(_refresh_ui)

func _refresh_ui():
	for c in categories_buttons_v_box.get_children():
		c.queue_free()
		categories_buttons_v_box.remove_child(c)
	for c in Upgrade.Category:
		var b = upgrade_category_button_scene.instantiate() as ResourceUpgradeCategoryButton
		b.resource = c
		b.pressed.connect(func(): category_pressed(c))
		categories_buttons_v_box.add_child(b)
	if _current_category:
		category_pressed(_current_category)
	else:
		category_pressed(Upgrade.Category.DRILL)
		
func category_pressed(category: Upgrade.Category):
	label.text = str(category)
