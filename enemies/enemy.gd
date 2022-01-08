extends KinematicBody2D


export(int) var health

remotesync func deal_damage(damage: int):
    print("dealt damage")
    health -= damage
    if health <= 0:
        queue_free()
