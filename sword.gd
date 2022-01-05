extends Sprite

export(NodePath) var animation_player_path

var animation_player: AnimationPlayer

func _ready():
    animation_player = get_node(animation_player_path)

# Signal
func _on_animation_finished(anim_name):
    if anim_name == "attack":
        animation_player.seek(0, true)

func swing():
    animation_player.play("attack")
