extends TextureRect
class_name Inventory

# Emitted when the action button is pressed
# on an item in the inventory
signal item_selected(inventory)

export(PackedScene) var inventory_icon_scene
export(NodePath) var selector_indicator

var inventory_size: int = 10
var inventory: Array = []

var selector_node: Node
var selected_index: int setget ,get_selected_index
var selected_item: ItemStack setget ,get_selected_item


# Called when the node enters the scene tree for the first time.
func _ready():
    for _x in range(inventory_size):
        inventory.append(null)
    selector_node = get_node(selector_indicator)

func get_selected_index():
    return selector_node.get_parent().get_index()

func get_selected_item() -> ItemStack:
    var sibling_index = get_selected_index()
    return inventory[sibling_index]

func remove_selected_item():
    var sibling_index = get_selected_index()
    var inventory_slot = get_child(sibling_index)
    var inventory_icon = inventory_slot.get_node("InventoryIcon")

    inventory[sibling_index] = null
    inventory_icon.queue_free()

func _input(event):
    if event is InputEventKey:
        var key_event = event as InputEventKey
        if key_event.scancode == KEY_RIGHT and key_event.is_pressed():
            var sibling_index = get_selected_index()
            # We use fposmod because -1 % 10 == -1 in gdscript :/
            var new_parent = get_child(fposmod(sibling_index + 1, get_child_count()) as int)
            selector_node.get_parent().remove_child(selector_node)
            new_parent.add_child(selector_node)
        elif key_event.scancode == KEY_LEFT and key_event.is_pressed():
            var sibling_index = get_selected_index()
            var new_parent = get_child(fposmod(sibling_index - 1, get_child_count()) as int)
            selector_node.get_parent().remove_child(selector_node)
            new_parent.add_child(selector_node)
        elif key_event.scancode == KEY_ENTER and key_event.is_pressed():
            var sibling_index = get_selected_index()
            if inventory[sibling_index] != null:
                emit_signal('item_selected', self)

func add_item(item_stack):
    var child = get_child(get_selected_index())
    if inventory[get_selected_index()] != null:
        var inventory_item_stack = inventory[get_selected_index()]
        inventory_item_stack.quantity += item_stack.quantity
        child.get_node("InventoryIcon").get_node("Label").set_text(inventory_item_stack.quantity as String)
    else:
        var item_icon = inventory_icon_scene.instance()
        var texture = item_icon.get_node("TextureRect")
        texture.texture = item_stack.item.inventory_texture
        inventory[get_selected_index()] = item_stack
        child.add_child(item_icon)
        child.get_node("InventoryIcon").get_node("Label").set_text(item_stack.quantity as String)
