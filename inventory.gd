extends TextureRect

export(PackedScene) var inventory_icon_scene
export(NodePath) var selector_indicator
export(StreamTexture) var iron_chunk_texture

var inventory_size: int = 10
var inventory: Array = []

var selector_node: Node
var selected_index: int setget ,get_selected_index

# Called when the node enters the scene tree for the first time.
func _ready():
    for x in range(inventory_size):
        inventory.append(null)
    selector_node = get_node(selector_indicator)

func get_selected_index():
    return selector_node.get_parent().get_index()

func _input(event):
    if event is InputEventKey:
        var key_event = event as InputEventKey
        if key_event.scancode == KEY_RIGHT and key_event.is_pressed():
            var sibling_index = selector_node.get_parent().get_index()
            # We use fposmod because -1 % 10 == -1 in gdscript :/
            var new_parent = get_child(fposmod(sibling_index + 1, get_child_count()) as int)
            selector_node.get_parent().remove_child(selector_node)
            new_parent.add_child(selector_node)
        elif key_event.scancode == KEY_LEFT and key_event.is_pressed():
            var sibling_index = selector_node.get_parent().get_index()
            var new_parent = get_child(fposmod(sibling_index - 1, get_child_count()) as int)
            selector_node.get_parent().remove_child(selector_node)
            new_parent.add_child(selector_node)
        elif key_event.scancode == KEY_UP and key_event.is_pressed():
            var child = get_child(get_selected_index())
            if inventory[get_selected_index()] != null:
                var item = inventory[get_selected_index()]
                item.quantity += 1
                child.get_node("InventoryIcon").get_node("Label").set_text(item.quantity as String)
            else:
                var item = Item.new()
                var item_icon = inventory_icon_scene.instance()
                var texture = item_icon.get_node("TextureRect")
                texture.texture = iron_chunk_texture
                item.inventory_image = iron_chunk_texture
                inventory[get_selected_index()] = item
                child.add_child(item_icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
