extends Node

var current_scene: Node = null

func load_scene(path) -> Node:
    var result = null
    if ResourceLoader.exists(path):
      result = ResourceLoader.load(path)
      return result.instantiate()
    return result

func _ready():
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)

# At some point this will handle the
# logic for blacking out the screen or whatever
# transition effect we want
func change_player_scene(node: Node, player):
    player.position = node.position

# The alternative is to change scenes deferred
# but that isn't useful anymore, because
# we teleport the player to new scenes instead of
# actually loading and unloading them
# I'm still keeping this function with this name
# just in case we want to bring that function back
func change_scene_immediate(scene_path):
    current_scene.queue_free()

    current_scene = load_scene(scene_path)

    get_tree().get_root().add_child(current_scene)

    get_tree().set_current_scene(current_scene)
    return current_scene
