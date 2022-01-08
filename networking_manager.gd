extends Node

export(NodePath) var players_list_path
export(NodePath) var server_ui_path
export(NodePath) var connecting_root_path
export(PackedScene) var main_scene
export(PackedScene) var player_scene

var players_list: Label
var server_ui: Node
var connecting_root: Control
var server: WebSocketServer
var peer: NetworkedMultiplayerENet

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
var players_done = []

# Called on everybody, even the new player, when a new player connects
func _player_connected(id):
    print(get_tree().network_peer)
    rpc_id(id, "register_player", get_info())
    print("Player connected! %d" % id)

func _player_disconnected(id):
    player_info.erase(id) # Erase player from info.

# Only called on clients, not server. Will go unused; not useful here.
func _connected_ok():
    print("Connected")
    connecting_root.visible = false

# Server kicked us; show error and abort.
func _server_disconnected():
    print("Server disconnected us")

# Could not even connect to server; abort.
func _connected_fail():
    print("didn't connect")

func clear_peers_list():
    players_list.text = ""

func _start_game():
    server = server_ui.server
    peer = server_ui.peer
    # Stop accepting new connections
    get_tree().set_refuse_new_network_connections(true)
    rpc("pre_configure_game")

func add_self_to_players():
    players_list.text += server_ui.get_name() + "\n"

remote func register_player(info):
    print("Registered")
    # Get the id of the RPC sender.
    var id = get_tree().get_rpc_sender_id()
    # Store the info
    player_info[id] = info
    players_list.text += info.name + "\n"
    print("player_info", player_info)

remotesync func pre_configure_game():
    print("start pre_configure_game")
    get_tree().set_pause(true)

    var selfPeerID = get_tree().get_network_unique_id()
    print(selfPeerID)

    # Load world
    var world = main_scene.instance()
    var root = get_node("/root")
    root.add_child(world)

    # Load my player
    var my_player = world.get_node("Player")
    my_player.set_name(str(selfPeerID))
    my_player.set_network_master(selfPeerID) # Will be explained later

    # Load other players
    for p in player_info:
        var player = player_scene.instance()
        player.set_name(str(p))
        player.set_network_master(p) # Will be explained later
        get_node("/root/World").add_child(player)

    my_player.get_node("Camera2D").current = true
    # Only clients should call the done_preconfiguring step
    if not get_tree().is_network_server():
        # Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
        # The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
        print("done preconfig")
        rpc_id(1, "done_preconfiguring")
        print("done postpreconfig")


remote func done_preconfiguring():
    var who = get_tree().get_rpc_sender_id()
    # Here are some checks you can do, for example
    assert(get_tree().is_network_server())
    assert(who in player_info) # Exists
    assert(not who in players_done) # Was not added yet

    players_done.append(who)
    print("players_done.size() = ", players_done.size(), ", player_info.size() = ", player_info.size())
    if players_done.size() == player_info.size():
        rpc("post_configure_game")

remotesync func post_configure_game():
    print("Post config")
    # Only the server is allowed to tell a client to unpause
    if get_tree().get_rpc_sender_id() == 1:
        get_tree().set_pause(false)
        # Game starts now!
        # Destroy the server lobby ui
        server_ui.queue_free()


# Gets the local players info
func get_info():
    return { name = server_ui.get_name() }
