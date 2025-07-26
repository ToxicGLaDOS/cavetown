extends StaticBody2D

signal _menu_closed

@export var chest_ui_path: NodePath

var chest_ui: ItemList
var contents: Array
var player: Player

func _ready():
	chest_ui = get_node(chest_ui_path)
	chest_ui.connect("item_selected", Callable(self, "_withdraw_item_stack"))

# Returns position in chest that has ItemStack
# with matching item
func find_item_in_chest(item: Item) -> int:
	for index in range(contents.size()):
		var item_stack = contents[index]
		if item_stack.item.id == item.id:
			return index

	return -1

func _add_item_stack(inventory: Inventory):
	var item_stack = inventory.selected_item
	var mergeable_position = find_item_in_chest(item_stack.item)
	if mergeable_position >= 0:
		contents[mergeable_position].quantity += item_stack.quantity
		chest_ui.set_item_text(mergeable_position, contents[mergeable_position].quantity as String)
	else:
		contents.append(item_stack)
		chest_ui.add_item(item_stack.quantity as String, item_stack.item.inventory_texture)

	inventory.remove_selected_item()

func _withdraw_item_stack(index: int):
	var item_stack = contents[index]

	contents.remove_at(index)
	chest_ui.remove_item(index)
	player.inventory.add_item(item_stack)

func _close_menu():
	chest_ui.visible = false
	emit_signal('_menu_closed')

func _on_menu_closed(inventory: Inventory):
	inventory.disconnect('item_selected', Callable(self, '_add_item_stack'))

# This looks like it would cause issues if another
# player activates while we're in the menu,
# but this is only called when local player activates
func player_activate(p: Player):
	chest_ui.visible = true
	player = p

	var inventory = player.inventory
	inventory = get_tree().get_nodes_in_group('inventory')[0]
	var err = inventory.connect('item_selected', Callable(self, '_add_item_stack'))
	if err != OK:
		push_error("Failed to connect signal item_selected. Error was %s." % err)

	connect('_menu_closed', Callable(self, '_on_menu_closed').bind(inventory), CONNECT_ONE_SHOT)
