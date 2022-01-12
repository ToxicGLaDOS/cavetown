extends CanvasLayer

# Path to the root of the ip input stuff
export(NodePath) var connect_gui_root_path
# Path to the root of the stuff shown when hosting
export(NodePath) var host_info_root_path
export(NodePath) var host_or_connect_root_path
export(NodePath) var back_button_path
export(NodePath) var ip_address_input_path
export(NodePath) var name_input_root_path
export(NodePath) var network_manager_path
export(NodePath) var connecting_root_path
export(NodePath) var players_list_path
export(NodePath) var disconnect_button_path
export(NodePath) var return_to_server_selection_path

var host_or_connect_root: Control
var connect_gui_root: Control
var host_info_root: Control
var host_button: Button
var connect_button: Button
var ip_address_input: TextEdit
var name_input_root: Control
var network_manager: Node
var connecting_root: Control
var players_list: Label
var disconnect_button: Button
var return_to_server_selection: Control

const SERVER_PORT = 42069
const MAX_PLAYERS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    host_or_connect_root = get_node(host_or_connect_root_path)
    host_info_root = get_node(host_info_root_path)
    connect_gui_root = get_node(connect_gui_root_path)
    ip_address_input = get_node(ip_address_input_path)
    name_input_root = get_node(name_input_root_path)
    network_manager = get_node(network_manager_path)
    connecting_root = get_node(connecting_root_path)
    players_list = get_node(players_list_path)
    disconnect_button = get_node(disconnect_button_path)
    return_to_server_selection = get_node(return_to_server_selection_path)

func show_no_scenes():
    host_or_connect_root.visible = false
    host_info_root.visible = false
    connecting_root.visible = false
    connect_gui_root.visible = false
    disconnect_button.visible = false
    name_input_root.visible = false
    return_to_server_selection.visible = false

func show_host_or_connect_scene():
    host_or_connect_root.visible = true
    name_input_root.visible = true

func show_hosting_scene():
    host_info_root.visible = true

func show_connecting_scene(): 
    connecting_root.visible = true

func show_connection_options_scene():
    connect_gui_root.visible = true
    name_input_root.visible = true

func show_disconnect_button():
    disconnect_button.visible = true

func show_return_to_server_selection_scene(text: String):
    return_to_server_selection.visible = true
    return_to_server_selection.get_node("Label").text = text

# Properly, isNativeServer should probably be an enum,
# but there _is_ only two options, and passing enum
# values to a signal doesn't seem to be possible
func _on_host_button_pressed(isNativeServer: bool):
    show_no_scenes()
    show_hosting_scene()
    add_player_to_list(get_name())
    network_manager.set_player_name(get_name())
    network_manager.host_server(SERVER_PORT, isNativeServer)

func _on_connect_button_pressed():
    show_no_scenes()
    show_connecting_scene()
    add_player_to_list(get_name())
    network_manager.set_player_name(get_name())

    var ip_address = ip_address_input.text
    network_manager.connect_to_server(ip_address, SERVER_PORT) 

func _on_connect_to_server_button_pressed():
    print("Pressed connect")
    show_no_scenes()
    show_connection_options_scene()

func _on_back_button_pressed():
    print("Back")
    show_no_scenes()
    show_host_or_connect_scene()
    clear_peers_list()
    network_manager.disconnect_from_network()

func _on_singleplayer_button_pressed():
    var world = network_manager.load_world()
    var player = world.get_node("Player")
    player.set_name_label(name_input_root.get_node("NameInput").text)
    queue_free()

func _on_start_button_pressed():
    network_manager.start_multiplayer_game()

func _on_return_to_server_selection_button_pressed():
    show_no_scenes()
    show_host_or_connect_scene()
    clear_peers_list()
    network_manager.disconnect_from_network()

func clear_peers_list():
    players_list.text = ""

func add_player_to_list(name: String):
    players_list.text += name + "\n"

func remove_player_from_list(name: String):
    var players = players_list.text.split("\n")
    # splits returns a PoolStringArray which doesn't
    # have the erase method :/
    for x in range(players.size()):
        if players[x] == name:
            players.remove(x)
            break

    players_list.text = players.join("\n")

func get_name():
    return name_input_root.get_node("NameInput").text
