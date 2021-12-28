extends TileMap

export(PackedScene) var iron_ore

var cell_data : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
    for x in range(10):
        var node = spawn_ore()
        var cell = world_to_map(node.position)
        set_cellv(cell, node.id)
        cell_data[cell] = node

func spawn_ore():
    var node = iron_ore.instance()
    var width = 16
    var height = 16 
    var x = randi() % 30
    var y = randi() % 30

    add_child(node)
    node.position = Vector2(x * 16 + width / 2, y * 16 + height / 2)
    return node


func hit_cell(x, y):
    var key = Vector2(x, y)
    if cell_data.has(key):
        cell_data[key].health -= 1
        if cell_data[key].health == 0:
                set_cell(x, y, -1)
                var drops = cell_data[key].destroy()
                for drop in drops:
                    add_child(drop)
                cell_data.erase(key)
                return true
    return false
