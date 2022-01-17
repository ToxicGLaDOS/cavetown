extends CanvasLayer

# Path to the root of the ip input stuff
export(NodePath) var connect_gui_root_path
# Path to the root of the stuff shown when hosting
export(NodePath) var host_info_root_path
export(NodePath) var host_or_connect_root_path
export(NodePath) var back_button_path
export(NodePath) var name_input_root_path
export(NodePath) var network_manager_path
export(NodePath) var players_list_path
export(NodePath) var return_to_server_selection_path

var host_or_connect_root: Control
var connect_gui_root: Control
var host_info_root: Control
var host_button: Button
var connect_button: Button
var name_input_root: Control
var network_manager: Node
var players_list: Label

# Called when the node enters the scene tree for the first time.
func _ready():
    host_or_connect_root = get_node(host_or_connect_root_path)
    host_info_root = get_node(host_info_root_path)
    connect_gui_root = get_node(connect_gui_root_path)
    name_input_root = get_node(name_input_root_path)
    network_manager = get_node(network_manager_path)
    players_list = get_node(players_list_path)

func show_no_scenes():
    host_or_connect_root.visible = false
    host_info_root.visible = false
    connect_gui_root.visible = false
    name_input_root.visible = false

func show_host_or_connect_scene():
    host_or_connect_root.visible = true
    name_input_root.visible = true

func show_hosting_options_scene():
    host_info_root.visible = true

func show_connection_options_scene():
    connect_gui_root.visible = true
    name_input_root.visible = true

# This function shows a scene in a child node
func show_return_to_server_selection_scene(text: String):
    connect_gui_root.visible = true
    connect_gui_root.show_return_to_server_selection_scene(text)
    clear_peers_list()

# Properly, isNativeServer should probably be an enum,
# but there _is_ only two options, and passing enum
# values to a signal doesn't seem to be possible
func _host_server(isNativeServer: bool):
    show_no_scenes()
    show_hosting_options_scene()
    add_player_to_list(get_name())
    network_manager.set_player_name(get_name())
    network_manager.host_server(host_info_root.get_port(), isNativeServer)

func _on_host_button_pressed():
    show_no_scenes()
    show_hosting_options_scene()

func connect_to_server():
    network_manager.set_player_name(get_name())
    name_input_root.visible = false

    var ip_address = connect_gui_root.get_ip()
    var port = connect_gui_root.get_port()
    network_manager.connect_to_server(ip_address, port)

func _on_connect_to_server_button_pressed():
    print("Pressed connect")
    show_no_scenes()
    show_connection_options_scene()

func disconnect_from_network():
    print("Disconnect from server")
    clear_peers_list()
    network_manager.disconnect_from_network()
    name_input_root.visible = true

func return_to_main_scene():
    print("Return to main")
    show_no_scenes()
    show_host_or_connect_scene()

func _on_singleplayer_button_pressed():
    var world = network_manager.load_world()
    var player = world.get_node("Player")
    player.set_name_label(get_name())
    queue_free()

func start_game():
    network_manager.start_multiplayer_game()

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
