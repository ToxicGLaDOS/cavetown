extends KinematicBody2D

export(NodePath) var inventory_path
export(NodePath) var sword_path
export(NodePath) var animated_sprite_path
export(NodePath) var interaction_area_path

export(float) var speed

var interaction_area: Area2D
var animated_sprite: AnimatedSprite
# The distance away from the character that we're hitting
var interaction_area_distance: float

enum Direction {UP, LEFT, DOWN, RIGHT}

puppet var puppet_pos = Vector2()

func _ready():
    interaction_area = get_node(interaction_area_path)
    animated_sprite = get_node(animated_sprite_path)
    interaction_area_distance = interaction_area.position.length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # Make sure that we only move ourselves
    if get_tree().network_peer == null or (get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED and is_network_master()):
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

        if get_tree().network_peer != null and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
            rset("puppet_pos", position)
    else:
        position = puppet_pos

func set_name_label(name: String):
    var name_label = get_node("NameLabel")
    name_label.text = name
    var min_size = name_label.get_minimum_size()
    name_label.rect_position = Vector2(-min_size.x / 2, name_label.rect_position.y)

remote func rotate_character(direction):
    if direction == Direction.UP:
        animated_sprite.animation = "up"
        interaction_area.position = Vector2(0, 2 * -interaction_area_distance)
        interaction_area.rotation_degrees = -90
    elif direction == Direction.LEFT:
        animated_sprite.animation = "left"
        interaction_area.position = Vector2(-interaction_area_distance, 0)
        interaction_area.rotation_degrees = 180
    elif direction == Direction.DOWN:
        animated_sprite.animation = "down"
        interaction_area.position = Vector2(0, 2 * interaction_area_distance)
        interaction_area.rotation_degrees = 90
    elif direction == Direction.RIGHT:
        animated_sprite.animation = "right"
        interaction_area.position = Vector2(interaction_area_distance, 0) 
        interaction_area.rotation_degrees = 0

remotesync func break_ore():
        var overlapping_bodies = interaction_area.get_overlapping_bodies()
        if overlapping_bodies.size() > 0:
            # TODO: Pick the best one
            var ore = overlapping_bodies[0]
            ore.hit()

# Called by an item to tell the player to pick it up
func pickup_item(item_stack):
    get_node("/root/World/CanvasLayer/Inventory").add_item(item_stack)


remotesync func swing_sword():
    get_node(sword_path).set_process(true)
    get_node(sword_path).swing()

func _input(event):
    if event is InputEventKey and event.pressed and event.scancode == KEY_SPACE:
        var overlapping_bodies = interaction_area.get_overlapping_bodies()
        if overlapping_bodies.size() > 0:
            # TODO: Pick the one closest to the middle maybe?
            var obj = overlapping_bodies[0]
            if obj.is_in_group('ore') and is_network_master():
                rpc("break_ore")
            elif obj.name == 'Mailbox':
                obj.player_activate()

    if event is InputEventKey and event.pressed and event.scancode == KEY_E:
        if is_network_master():
            rpc("swing_sword")
