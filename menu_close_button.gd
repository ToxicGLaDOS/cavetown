extends Button

export(NodePath) var menu_path

var menu: Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    menu = get_node(menu_path)
    connect("pressed", self, "_close_menu")

func _close_menu():
    menu.visible = false
