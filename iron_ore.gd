extends Node2D


export(PackedScene) var iron_chunk

const id: int  = 0
var health: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func destroy():
    var node = iron_chunk.instance()
    node.position = position
    queue_free()
    return [node]

func _init():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
