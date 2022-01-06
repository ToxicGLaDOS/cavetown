extends Node2D 


export(Resource) var item

# Connected to body_entered(body) signal
func _on_body_entered(body):
    if body.is_in_group("player"):
        var item_stack = ItemStack.new()
        item_stack.item = item
        item_stack.quantity = 1
        body.pickup_item(item_stack)
        queue_free()
