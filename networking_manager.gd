extends Node

export(NodePath) var players_list_path
export(NodePath) var server_ui_path
export(NodePath) var connecting_root_path


var players_list: Label
var server_ui: Node
var connecting_root: Control

func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")
    players_list = get_node(players_list_path)
    server_ui = get_node(server_ui_path)
    connecting_root = get_node(connecting_root_path)

# Player info, associate ID to data
var player_info = {}

# Called on both clients and server when a peer connects. Send my info to it.
func _player_connected(id):
    rpc_id(id, "register_player", get_info())
    print("Player connected! %d" % id)

func _player_disconnected(id):
    player_info.erase(id) # Erase player from info.

# Only called on clients, not server. Will go unused; not useful here.
func _connected_ok():
    print("Connected")
    connecting_root.visible = false
    # Register ourselves
    register_player(get_info())

# Server kicked us; show error and abort.
func _server_disconnected():
    print("Server disconnected us")

# Could not even connect to server; abort.
func _connected_fail():
    print("didn't connect")

func clear_peers_list():
    players_list.text = ""

remote func register_player(info):
    print("Registered")
    # Get the id of the RPC sender.
    var id = get_tree().get_rpc_sender_id()
    # Store the info
    player_info[id] = info
    players_list.text += info.name + "\n"

# Gets the local players info
func get_info():
    return { name = server_ui.get_name() }
