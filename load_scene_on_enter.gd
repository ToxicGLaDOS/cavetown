extends Area2D

@export var connected_node_path: NodePath

var connected_node

# Called when the node enters the scene tree for the first time.
func _ready():
    var err = connect('body_entered', Callable(self, '_on_body_entered'))
    if err != OK:
        push_error("Failed to connect signal body_entered. Error was %s" % err)

    connected_node = get_node(connected_node_path)


func _on_body_entered(body):
    if body.is_in_group("player"):
        SceneSwitcher.change_player_scene(connected_node, body)
