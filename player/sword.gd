extends Sprite2D

@export var animation_player_path: NodePath
@export var hitbox_path: NodePath

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
    if body.is_in_group("enemies"):
        body.deal_damage(1)

func swing():
    visible = true
    hitbox.monitoring = true
    animation_player.play("attack")

