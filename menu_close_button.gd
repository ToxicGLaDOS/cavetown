extends Button

export(NodePath) var menu_path

var menu: Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    menu = get_node(menu_path)
    var err = connect("pressed", self, "_close_menu")
    if err != OK:
        push_error("Failed to connect signal pressed. Error was %s" % err)

func _close_menu():
    menu.visible = false
