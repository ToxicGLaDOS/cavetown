extends CanvasLayer

# Path to the root of the ip input stuff
export(NodePath) var connect_gui_root_path
# Path to the root of the stuff shown when hosting
export(NodePath) var host_info_root_path
export(NodePath) var host_button_path
export(NodePath) var connect_button_path
export(NodePath) var connect_to_server_button_path
export(NodePath) var back_button_path
export(NodePath) var ip_address_input_path
export(NodePath) var name_input_root_path
export(NodePath) var network_manager_path
export(NodePath) var connecting_root_path

var connect_gui_root: Control
var host_info_root: Control
var host_button: Button
var connect_button: Button
var connect_to_server_button: Button
var back_button: Button
var ip_address_input: TextEdit
var name_input_root: Control
var network_manager: Node
var connecting_root: Control
var server: WebSocketServer
var client: WebSocketClient
var peer: NetworkedMultiplayerENet

const SERVER_PORT = 42069
const MAX_PLAYERS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    host_button = get_node(host_button_path)
    host_info_root = get_node(host_info_root_path)
    connect_button = get_node(connect_button_path)
    connect_gui_root = get_node(connect_gui_root_path)
    back_button = get_node(back_button_path)
    connect_to_server_button = get_node(connect_to_server_button_path)
    ip_address_input = get_node(ip_address_input_path)
    name_input_root = get_node(name_input_root_path)
    network_manager = get_node(network_manager_path)
    connecting_root = get_node(connecting_root_path)

func _process(delta):
    if server != null:
        if server.is_listening():
            server.poll()
    if client != null:
        if client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED or client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
            client.poll()

func _on_host_button_pressed():
    print("Pressed host")
    host_info_root.visible = true
    back_button.visible = true
    host_button.visible = false
    connect_to_server_button.visible = false
    name_input_root.visible = false
    network_manager.add_self_to_players()

    server = WebSocketServer.new()
    server.listen(SERVER_PORT, PoolStringArray(), true)
    get_tree().set_network_peer(server)

    peer = NetworkedMultiplayerENet.new()
    peer.create_server(SERVER_PORT, MAX_PLAYERS)
    #get_tree().set_network_peer(peer)
    #server.connect("network_peer_connected", self, "foo")

func foo():
    print("OMGOMODMOGMOGMOMGOMGOMGO")

func _on_connect_button_pressed():
    connect_to_server_button.visible = false
    connect_gui_root.visible = false
    name_input_root.visible = false
    connecting_root.visible = true
    network_manager.add_self_to_players()
    
    var ip_address = ip_address_input.text
    if OS.get_name() == "HTML5":
        var url = "ws://" + ip_address + ":" + SERVER_PORT as String
        client = WebSocketClient.new()
        var error = client.connect_to_url(url, PoolStringArray(), true)
        get_tree().network_peer = client
        print(error)
    else:
        var peer = NetworkedMultiplayerENet.new()
        peer.create_client(ip_address, SERVER_PORT)
        get_tree().network_peer = peer

func _on_connect_to_server_button_pressed():
    print("Pressed connect")
    connect_gui_root.visible = true
    host_button.visible = false
    connect_to_server_button.visible = false

func _on_back_button_pressed():
    print("Back")
    connect_gui_root.visible = false
    host_info_root.visible = false
    connect_to_server_button.visible = true
    host_button.visible = true
    back_button.visible = false
    name_input_root.visible = true
    network_manager.clear_peers_list()
    get_tree().network_peer = null


func get_name():
    return name_input_root.get_node("NameInput").text
