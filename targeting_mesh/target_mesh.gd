extends MeshInstance2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bar_width = 2
var width = 16
export(NodePath) var player

# Called when the node enters the scene tree for the first time.
func _ready():
    var vertices = PoolVector3Array()
    vertices.push_back(Vector3(0, 0, 0))
    vertices.push_back(Vector3(width, 0, 0))
    vertices.push_back(Vector3(0, bar_width, 0))
    
    vertices.push_back(Vector3(0, bar_width, 0))
    vertices.push_back(Vector3(width, 0, 0))
    vertices.push_back(Vector3(width, bar_width, 0))
    
    vertices.push_back(Vector3(width, 0, 0))
    vertices.push_back(Vector3(width, width, 0))
    vertices.push_back(Vector3(width - bar_width, 0, 0))
    
    vertices.push_back(Vector3(width - bar_width, 0, 0))
    vertices.push_back(Vector3(width, width, 0))
    vertices.push_back(Vector3(width - bar_width, width, 0))
    
    vertices.push_back(Vector3(width, width, 0))
    vertices.push_back(Vector3(0, width, 0))
    vertices.push_back(Vector3(width, width - bar_width, 0))
    
    vertices.push_back(Vector3(width, width - bar_width, 0))
    vertices.push_back(Vector3(0, width, 0))
    vertices.push_back(Vector3(0, width - bar_width, 0))
    
    vertices.push_back(Vector3(0, width, 0))
    vertices.push_back(Vector3(0, 0, 0))
    vertices.push_back(Vector3(bar_width, width, 0))
    
    vertices.push_back(Vector3(0, 0, 0))
    vertices.push_back(Vector3(bar_width, 0, 0))
    vertices.push_back(Vector3(bar_width, width, 0))
    
    
    # Initialize the ArrayMesh.
    var arr_mesh = mesh
    var arrays = []
    arrays.resize(ArrayMesh.ARRAY_MAX)
    arrays[ArrayMesh.ARRAY_VERTEX] = vertices
    # Create the Mesh.
    arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    var m = MeshInstance.new()
    m.mesh = arr_mesh


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
        var x = floor(get_node(player).global_position.x / 16) * 16
        var y = floor(get_node(player).global_position.y / 16) * 16
        position = Vector2(x, y)





