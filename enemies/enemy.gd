extends KinematicBody2D


export(int) var health

func deal_damage(damage: int):
    health -= damage
    if health <= 0:
        queue_free()
