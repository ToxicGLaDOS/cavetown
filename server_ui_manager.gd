extends CanvasLayer

# Path to the root of the ip input stuff
export(NodePath) var connect_gui_root_path
# Path to the root of the stuff shown when hosting
export(NodePath) var host_info_root_path
export(NodePath) var host_or_connect_root_path
export(NodePath) var connect_to_server_button_path
export(NodePath) var back_button_path
export(NodePath) var ip_address_input_path
export(NodePath) var name_input_root_path
export(NodePath) var network_manager_path
export(NodePath) var connecting_root_path
export(NodePath) var players_list_path
export(NodePath) var disconnect_button_path

var host_or_connect_root: Control
var connect_gui_root: Control
var host_info_root: Control
var host_button: Button
var connect_button: Button
var connect_to_server_button: Button
var ip_address_input: TextEdit
var name_input_root: Control
var network_manager: Node
var connecting_root: Control
var players_list: Label
var disconnect_button: Button

const SERVER_PORT = 42069
const MAX_PLAYERS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    host_or_connect_root = get_node(host_or_connect_root_path)
    host_info_root = get_node(host_info_root_path)
    connect_gui_root = get_node(connect_gui_root_path)
    connect_to_server_button = get_node(connect_to_server_button_path)
    ip_address_input = get_node(ip_address_input_path)
    name_input_root = get_node(name_input_root_path)
    network_manager = get_node(network_manager_path)
    connecting_root = get_node(connecting_root_path)
    players_list = get_node(players_list_path)
    disconnect_button = get_node(disconnect_button_path)

func on_host_button_pressed():
    print("Pressed host")
    host_info_root.visible = true
    name_input_root.visible = false
    host_or_connect_root.visible = false
    add_player_to_list(get_name())

func initial_menu():
    host_or_connect_root.visible = true

func _on_host_native_button_pressed():
    on_host_button_pressed()
    network_manager.set_player_name(get_name())

    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(SERVER_PORT, MAX_PLAYERS)
    get_tree().set_network_peer(peer)

func _on_host_web_button_pressed():
    on_host_button_pressed()
    network_manager.set_player_name(get_name())

    var peer = WebSocketServer.new()
    peer.listen(SERVER_PORT, PoolStringArray(), true)
    get_tree().set_network_peer(peer)

func _on_connect_button_pressed():
    connect_gui_root.visible = false
    name_input_root.visible = false
    connecting_root.visible = true
    add_player_to_list(get_name())
    network_manager.set_player_name(get_name())
    
    var ip_address = ip_address_input.text
    if OS.get_name() == "HTML5":
        var url = "ws://" + ip_address + ":" + SERVER_PORT as String
        var client = WebSocketClient.new()
        client.connect_to_url(url, PoolStringArray(), true)
        get_tree().network_peer = client
    else:
        var peer = NetworkedMultiplayerENet.new()
        peer.create_client(ip_address, SERVER_PORT)
        get_tree().network_peer = peer

func _on_connect_to_server_button_pressed():
    print("Pressed connect")
    connect_gui_root.visible = true
    host_or_connect_root.visible = false

func _on_back_button_pressed():
    print("Back")
    connect_gui_root.visible = false
    host_info_root.visible = false
    host_or_connect_root.visible = true
    disconnect_button.visible = false
    connecting_root.visible = false
    name_input_root.visible = true
    clear_peers_list()
    network_manager.disconnect_from_network()

func _on_singleplayer_button_pressed():
    var world = network_manager.load_world()
    var player = world.get_node("Player")
    player.set_name_label(name_input_root.get_node("NameInput").text)
    queue_free()

func _on_start_button_pressed():
    network_manager.start_game()

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
