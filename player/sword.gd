extends Sprite

export(NodePath) var animation_player_path
export(NodePath) var hitbox_path

var animation_player: AnimationPlayer
var hitbox: Area2D

func _ready():
    animation_player = get_node(animation_player_path)
    hitbox = get_node(hitbox_path)

# Signal
func _on_animation_finished(anim_name):
    if anim_name == "attack":
        animation_player.seek(0, true)
        visible = false
        hitbox.monitoring = false

func _on_body_entered(body):
    # We only want the network master to tell us when they
    # hit an enemy because if everyone does it, then we'll
    # deal 1 damage per player when anyone hits an enemy
    if body.is_in_group("enemies") and is_network_master():
        print("hit slime")
        body.rpc("deal_damage", 1)

func swing():
    visible = true
    hitbox.monitoring = true
    animation_player.play("attack")

