extends StaticBody2D

export(int) var durability
export(PackedScene) var iron_chunk

var health

func _ready():
    health = durability

func hit():
    health -= 1
    if health <= 0:
        var node = iron_chunk.instance()
        get_parent().add_child(node)
        node.position = position
        queue_free()
