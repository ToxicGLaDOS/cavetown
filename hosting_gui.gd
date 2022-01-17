extends Control

signal host_native_server
signal host_web_server
signal stop_hosting
signal close_scene
signal start_game

export(NodePath) var host_native_button_path
export(NodePath) var host_web_button_path
export(NodePath) var port_input_path
export(NodePath) var close_button_path
export(NodePath) var back_button_path
export(NodePath) var start_button_path
export(NodePath) var lobby_path
export(NodePath) var hosting_options_path

var host_native_button: Button
var host_web_button: Button
var close_button: Button
var back_button: Button
var start_button: Button
var port_input: TextEdit
var lobby: Control
var hosting_options: Control

func _ready():
    host_native_button = get_node(host_native_button_path)
    host_web_button = get_node(host_web_button_path)
    back_button = get_node(back_button_path)
    start_button = get_node(start_button_path)
    close_button = get_node(close_button_path)
    port_input = get_node(port_input_path)
    lobby = get_node(lobby_path)
    hosting_options = get_node(hosting_options_path)

    host_native_button.connect("pressed", self, "emit_signal", ["host_native_server"])
    host_web_button.connect("pressed", self, "emit_signal", ["host_web_server"])
    back_button.connect("pressed", self, "emit_signal", ["stop_hosting"])
    close_button.connect("pressed", self, "emit_signal", ["close_scene"])
    start_button.connect("pressed", self, "emit_signal", ["start_game"])

func get_port():
    return port_input.text as int

func show_hosting_options():
    lobby.visible = false
    hosting_options.visible = true

func show_hosting():
    lobby.visible = true
    hosting_options.visible = false
