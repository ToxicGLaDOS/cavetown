extends CanvasLayer

# Path to the root of the ip input stuff
export(NodePath) var connect_gui_root_path
# Path to the root of the stuff shown when hosting
export(NodePath) var host_info_root_path
export(NodePath) var host_or_connect_root_path
export(NodePath) var back_button_path
export(NodePath) var name_input_root_path
export(NodePath) var players_list_path

var host_or_connect_root: Control
var connect_gui_root: Control
var host_info_root: Control
var host_button: Button
var connect_button: Button
var name_input_root: Control
var players_list: Label

# Called when the node enters the scene tree for the first time.
func _ready():
    host_or_connect_root = get_node(host_or_connect_root_path)
    host_info_root = get_node(host_info_root_path)
    connect_gui_root = get_node(connect_gui_root_path)
    name_input_root = get_node(name_input_root_path)
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

func _host_server():
    add_player_to_list(get_name())
    NetworkManager.set_player_name(get_name())

func _on_host_button_pressed():
    show_no_scenes()
    show_hosting_options_scene()

func _connect_to_server():
    NetworkManager.set_player_name(get_name())
    name_input_root.visible = false

    var ip_address = connect_gui_root.get_ip()
    var port = connect_gui_root.get_port()
    NetworkManager.connect_to_server(ip_address, port)

func _on_connect_to_server_button_pressed():
    print("Pressed connect")
    show_no_scenes()
    show_connection_options_scene()

func _disconnect_from_network():
    print("Disconnect from server")
    clear_peers_list()
    NetworkManager.disconnect_from_network()
    name_input_root.visible = true

func _return_to_main_scene():
    print("Return to main")
    show_no_scenes()
    show_host_or_connect_scene()

func _on_singleplayer_button_pressed():
    var world = NetworkManager.load_world()
    NetworkManager.load_player(get_name(), 1, world)

func _start_game():
    NetworkManager.start_multiplayer_game()

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
