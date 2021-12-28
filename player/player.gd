extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var tilemap_path
export(NodePath) var hit_position_path

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func break_ore():
        var hit_position = get_node(hit_position_path).global_position
        var tilemap = get_node(tilemap_path)
        
        var hit_x = floor(hit_position.x / tilemap.cell_size.x)
        var hit_y = floor(hit_position.y / tilemap.cell_size.y)
        
        var hit_cell = tilemap.hit_cell(hit_x, hit_y)

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
        break_ore()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
