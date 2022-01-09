extends KinematicBody2D

export(NodePath) var tilemap_path
export(NodePath) var hit_position_path
export(NodePath) var inventory_path
export(NodePath) var sword_path
export(NodePath) var animated_sprite_path

export(float) var speed

var tilemap: TileMap
var hit_position: Position2D
var animated_sprite: AnimatedSprite
# The distance away from the character that we're hitting
var hit_position_distance: float

enum Direction {UP, LEFT, DOWN, RIGHT}

puppet var puppet_pos = Vector2()

func _ready():
    tilemap = get_node("/root/World/Ore")
    hit_position = get_node(hit_position_path)
    animated_sprite = get_node(animated_sprite_path)
    hit_position_distance = hit_position.position.length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # Make sure that we only move ourselves
    if get_tree().network_peer == null or is_network_master():
        if Input.is_key_pressed(KEY_W):
            move_and_slide(Vector2(0, -1) * speed * delta)
            if get_tree().network_peer != null:
                rpc("rotate_character", Direction.UP)
            rotate_character(Direction.UP)
        if Input.is_key_pressed(KEY_A):
            move_and_slide(Vector2(-1, 0) * speed * delta)
            if get_tree().network_peer != null:
                rpc("rotate_character", Direction.LEFT)
            rotate_character(Direction.LEFT)
        if Input.is_key_pressed(KEY_S):
            move_and_slide(Vector2(0, 1) * speed * delta)
            if get_tree().network_peer != null:
                rpc("rotate_character", Direction.DOWN)
            rotate_character(Direction.DOWN)
        if Input.is_key_pressed(KEY_D):
            move_and_slide(Vector2(1, 0) * speed * delta)
            if get_tree().network_peer != null:
                rpc("rotate_character", Direction.RIGHT)
            rotate_character(Direction.RIGHT)

        if get_tree().network_peer != null:
            rset("puppet_pos", position)
    else:
        position = puppet_pos


remote func rotate_character(direction):
    if direction == Direction.UP:
        animated_sprite.animation = "up"
        hit_position.position = Vector2(0, 2 * -hit_position_distance)
        hit_position.rotation_degrees = -90
    elif direction == Direction.LEFT:
        animated_sprite.animation = "left"
        hit_position.position = Vector2(-hit_position_distance, 0)
        hit_position.rotation_degrees = 180
    elif direction == Direction.DOWN:
        animated_sprite.animation = "down"
        hit_position.position = Vector2(0, 2 * hit_position_distance)
        hit_position.rotation_degrees = 90
    elif direction == Direction.RIGHT:
        animated_sprite.animation = "right"
        hit_position.position = Vector2(hit_position_distance, 0) 
        hit_position.rotation_degrees = 0

remotesync func break_ore():
        var position = hit_position.global_position
        
        var hit_x = floor(position.x / tilemap.cell_size.x)
        var hit_y = floor(position.y / tilemap.cell_size.y)
        
        var hit_cell = tilemap.hit_cell(hit_x, hit_y)

# Called by an item to tell the player to pick it up
func pickup_item(item_stack):
    get_node("/root/World/CanvasLayer/Inventory").add_item(item_stack)


remotesync func swing_sword():
    get_node(sword_path).set_process(true)
    get_node(sword_path).swing()

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
        if get_tree().network_peer == null:
            break_ore()
        elif is_network_master():
            rpc("break_ore")

    if event is InputEventKey and event.pressed and event.scancode == KEY_E:
        if get_tree().network_peer == null:
            swing_sword()
        elif is_network_master():
            rpc("swing_sword")
