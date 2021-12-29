extends Node2D 


export(Resource) var item

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Connected to body_entered(body) signal
func _on_body_entered(body):
    # TODO: This seems error prone. Probably change this later
    if body.get_parent().name == "Player":
        var item_stack = ItemStack.new()
        item_stack.item = item
        item_stack.quantity = 1
        body.get_parent().pickup_item(item_stack)
        queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
