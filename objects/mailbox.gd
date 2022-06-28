extends Node

export(NodePath) var mail_menu_path

var mail_menu

# Called when the node enters the scene tree for the first time.
func _ready():
    mail_menu = get_node(mail_menu_path)


func player_activate():
    mail_menu.visible = true
