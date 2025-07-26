extends CharacterBody2D


@export var health: int
@export var base_damage: int

func deal_damage(damage: int):
    health -= damage
    if health <= 0:
        queue_free()

func _on_body_entered(body: Node):
    if body.is_in_group('player'):
        body.deal_damage(base_damage)
