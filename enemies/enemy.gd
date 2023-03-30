extends KinematicBody2D


export(int) var health
export(int) var base_damage

remotesync func deal_damage(damage: int):
    print("dealt damage")
    health -= damage
    if health <= 0:
        queue_free()

func _on_body_entered(body: Node):
    if body.is_in_group('player'):
        body.deal_damage(base_damage)
