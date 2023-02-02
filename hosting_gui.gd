extends Control

signal host_server

# These signals are called in a way that can't be detected
# so they have erroneous warnings which we ignore
# warning-ignore:unused_signal
signal stop_hosting
# warning-ignore:unused_signal
signal close_scene
# warning-ignore:unused_signal
signal start_game

export(NodePath) var host_button_path
export(NodePath) var port_input_path
export(NodePath) var close_button_path
export(NodePath) var back_button_path
export(NodePath) var start_button_path
export(NodePath) var lobby_path
export(NodePath) var hosting_options_path

var host_button: Button
var close_button: Button
var back_button: Button
var start_button: Button
var port_input: TextEdit
var lobby: Control
var hosting_options: Control

func _ready():
    host_button = get_node(host_button_path)
    back_button = get_node(back_button_path)
    start_button = get_node(start_button_path)
    close_button = get_node(close_button_path)
    port_input = get_node(port_input_path)
    lobby = get_node(lobby_path)
    hosting_options = get_node(hosting_options_path)

    var err = back_button.connect("pressed", self, "emit_signal", ["stop_hosting"])
    if err != OK:
        push_error("Failed to connect signal connection_failed. Error was %s" % err)

    err = close_button.connect("pressed", self, "emit_signal", ["close_scene"])
    if err != OK:
        push_error("Failed to connect signal connection_failed. Error was %s" % err)

    err = start_button.connect("pressed", self, "emit_signal", ["start_game"])
    if err != OK:
        push_error("Failed to connect signal connection_failed. Error was %s" % err)

func _on_host_button_pressed():
    var error = NetworkManager.host_server(get_port())
    if not error:
        emit_signal("host_server")
        show_hosting()
    else:
        print("Couldn't host server: error code %s" % error as String)

func get_port():
    return port_input.text as int

func show_hosting_options():
    lobby.visible = false
    hosting_options.visible = true

func show_hosting():
    lobby.visible = true
    hosting_options.visible = false
