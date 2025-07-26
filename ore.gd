extends StaticBody2D

@export var durability: int
@export var iron_chunk: PackedScene

var health

func _ready():
    health = durability

func hit():
    health -= 1
    if health <= 0:
        var node = iron_chunk.instantiate()
        get_parent().add_child(node)
        node.position = position
        queue_free()
