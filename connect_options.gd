extends Control

signal close_scene
signal connect_to_server
signal disconnect_from_server

export(NodePath) var ip_input_path
export(NodePath) var port_input_path
export(NodePath) var back_button_path
export(NodePath) var connect_button_path
export(NodePath) var disconnect_button_path
export(NodePath) var cancel_button_path
export(NodePath) var connection_options_path
export(NodePath) var connecting_scene_path
export(NodePath) var return_to_server_selection_path

var ip_input: TextEdit
var port_input: TextEdit
var back_button: Button
var connect_button: Button
var disconnect_button: Button
var cancel_button: Button
var connecting_scene: Control
var connection_options: Control
var return_to_server_selection: Control

func _ready():
    ip_input = get_node(ip_input_path)
    port_input = get_node(port_input_path)
    back_button = get_node(back_button_path)
    connect_button = get_node(connect_button_path)
    disconnect_button = get_node(disconnect_button_path)
    cancel_button = get_node(cancel_button_path)
    connecting_scene = get_node(connecting_scene_path)
    connection_options = get_node(connection_options_path)
    return_to_server_selection = get_node(return_to_server_selection_path)

    get_tree().connect("connection_failed", self, "_connection_fail")
    get_tree().connect("connected_to_server", self, "_connected_to_server")

    # Used to pass the button press singals through to the server_ui_manager
    back_button.connect("pressed", self, "emit_signal", ["close_scene"])
    connect_button.connect("pressed", self, "emit_signal", ["connect_to_server"])
    disconnect_button.connect("pressed", self, "emit_signal", ["disconnect_from_server"])
    cancel_button.connect("pressed", self, "emit_signal", ["disconnect_from_server"])

# We handle connection_failed here, but not server_disconnected
# because we have to accept the case where the server_disconnected
# signal is emitted while this node doesn't exist (we're already in game)
# 
# To handle that case we need a path in the code from networking_manager
# to this node so that we can instance a server_ui and then hide everything
# except the return_to_server_selection stuff. So, for consistency, we
# just always use that code path instead of splitting it up based on
# whether or not this node exists
func _connection_fail():
    show_return_to_server_selection_scene("Couldn't connect to server")

func _connected_to_server():
    show_disconnect_scene()

func show_no_scenes():
    connecting_scene.visible = false
    connection_options.visible = false
    return_to_server_selection.visible = false
    disconnect_button.visible = false

func show_disconnect_scene():
    show_no_scenes()
    disconnect_button.visible = true

func show_return_to_server_selection_scene(text: String):
    show_no_scenes()
    return_to_server_selection.get_node("Label").text = text
    return_to_server_selection.visible = true

func show_connecting_scene():
    show_no_scenes()
    connecting_scene.visible = true

func show_connection_options_scene():
    show_no_scenes()
    connection_options.visible = true

func get_ip():
    return ip_input.text

func get_port():
    return port_input.text as int
