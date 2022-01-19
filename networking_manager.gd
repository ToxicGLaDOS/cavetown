extends Node

var main_scene
var player_scene
var server_selection_scene

var server_ui: Node
const MAX_PLAYERS = 4

func _ready():
    get_tree().connect("network_peer_connected", self, "_player_connected")
    get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
    get_tree().connect("connected_to_server", self, "_connected_ok")
    get_tree().connect("connection_failed", self, "_connected_fail")
    get_tree().connect("server_disconnected", self, "_server_disconnected")
    server_ui = get_node("/root/ServerSelection")
    main_scene = load("res://main.tscn")
    player_scene = load("res://player/player.tscn")
    server_selection_scene = load("res://server_selection_ui.tscn")

    # TODO: Negotiate with the server over a seed when connecting
    # instead of having the same one every time
    seed(0)
    
# Player info, associate ID to data
var my_info = {}
var player_info = {}
var players_done = []

func set_player_name(name: String):
    my_info["name"] = name

func disconnect_from_network():
    player_info.clear()
    get_tree().network_peer = null

func host_server(port: int):
    var peer = WebSocketServer.new()
    var error = peer.listen(port, PoolStringArray(), true)
    if not error:
        get_tree().set_network_peer(peer)
    return error

func connect_to_server(ip_address: String, port: int):
    # We only use websockets so that native clients
    # and web clients can play together
    var url = "ws://" + ip_address + ":" + port as String
    var peer = WebSocketClient.new()
    peer.connect_to_url(url, PoolStringArray(), true)
    peer.connect("server_close_request", self, "_server_close_request")

    get_tree().network_peer = peer

# Called when a WebSocketClient is requested to disconnect
# We just forward it to the normal _server_disconnected logic
func _server_close_request(code: int, reason: String):
    _server_disconnected()

# Called on both clients and server when a peer connects. Send my info to it.
func _player_connected(id):
    print(get_tree().network_peer)
    rpc_id(id, "register_player", my_info)
    print("Player connected! %d" % id)

func _player_disconnected(id):
    if has_node("/root/World"):
        var world = get_node("/root/World")
        world.get_node(str(id)).queue_free()
    else:
        server_ui.remove_player_from_list(player_info[id]["name"])
    player_info.erase(id) # Erase player from info.

# Only called on clients, not server
func _connected_ok():
    print("Connected")
    server_ui.add_player_to_list(server_ui.get_name())
    seed(0)

# Server kicked us; show error and abort.
func _server_disconnected():
    print("disconnected")
    if has_node("/root/World"):
        var world = get_node("/root/World")
        world.queue_free()

    # This happens when we get kicked after the game has loaded
    if not is_instance_valid(server_ui):
        server_ui = server_selection_scene.instance()
        add_child(server_ui)

    server_ui.show_no_scenes()
    server_ui.show_return_to_server_selection_scene("Server disconnected us :(")
    player_info.clear()

# Could not even connect to server; abort.
func _connected_fail():
    pass

func start_multiplayer_game():
    # Only the host should be able to start the game
    if get_tree().get_network_unique_id() == 1:
        # Stop accepting new connections
        get_tree().set_refuse_new_network_connections(true)
        rpc("pre_configure_game")

remote func register_player(info):
    print("Registered")
    # Get the id of the RPC sender.
    var id = get_tree().get_rpc_sender_id()
    # Store the info
    player_info[id] = info
    server_ui.add_player_to_list(info["name"])
    print("player_info", player_info)

func load_world():
    # Load world
    var world = main_scene.instance()
    var root = get_node("/root")
    root.add_child(world)

    return world

remotesync func pre_configure_game():
    print("start pre_configure_game")
    get_tree().set_pause(true)

    var selfPeerID = get_tree().get_network_unique_id()
    print(selfPeerID)

    var world = load_world()

    # Load my player
    var my_player = world.get_node("Player")
    my_player.set_name(str(selfPeerID))
    my_player.set_name_label(my_info['name'])
    my_player.set_network_master(selfPeerID) # Will be explained later

    # Load other players
    for p in player_info:
        var player = player_scene.instance()
        player.set_name(str(p))
        player.set_network_master(p) # Will be explained later
        get_node("/root/World").add_child(player)
        player.set_name_label(player_info[p]["name"])

    my_player.get_node("Camera2D").current = true
    # Only clients should call the done_preconfiguring step
    if not get_tree().is_network_server():
        # Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
        # The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
        print("done preconfig")
        rpc_id(1, "done_preconfiguring")
        print("done postpreconfig")

    # If we started the game with no one else in the lobby
    # then start the game
    if get_tree().is_network_server() and player_info.size() == 0:
        post_configure_game()


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

