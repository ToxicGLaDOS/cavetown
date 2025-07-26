extends CharacterBody2D
class_name Player


@export var inventory_path: NodePath
@export var sword_path: NodePath
@export var animated_sprite_path: NodePath
@export var interaction_area_path: NodePath

@export var speed: float
@export var health: int

var interaction_area: Area2D
var animated_sprite: AnimatedSprite2D
# The distance away from the character that we're hitting
var interaction_area_distance: float
var inventory: Node

enum Direction {UP, LEFT, DOWN, RIGHT}

func _ready():
	interaction_area = get_node(interaction_area_path)
	animated_sprite = get_node(animated_sprite_path)
	inventory = get_tree().get_nodes_in_group('inventory')[0]
	interaction_area_distance = interaction_area.position.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Make sure that we only move ourselves

	if Input.is_key_pressed(KEY_W):
		# warning-ignore:return_value_discarded
		set_velocity(Vector2(0, -1) * speed * delta)
		move_and_slide()
		rotate_character(Direction.UP)

	if Input.is_key_pressed(KEY_A):
		# warning-ignore:return_value_discarded
		set_velocity(Vector2(-1, 0) * speed * delta)
		move_and_slide()
		rotate_character(Direction.LEFT)

	if Input.is_key_pressed(KEY_S):
		# warning-ignore:return_value_discarded
		set_velocity(Vector2(0, 1) * speed * delta)
		move_and_slide()
		rotate_character(Direction.DOWN)

	if Input.is_key_pressed(KEY_D):
		# warning-ignore:return_value_discarded
		set_velocity(Vector2(1, 0) * speed * delta)
		move_and_slide()
		rotate_character(Direction.RIGHT)

func on_death():
	position = Vector2(0, 0)
	

func deal_damage(damage: int):
	health -= damage
	if health <= 0:
		on_death()

func set_name_label(label: String):
	var name_label = get_node("NameLabel")
	name_label.text = label
	var min_size = name_label.get_minimum_size()
	name_label.position = Vector2(-min_size.x / 2, name_label.position.y)

func rotate_character(direction):
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

func break_ore():
		var overlapping_bodies = interaction_area.get_overlapping_bodies()
		if overlapping_bodies.size() > 0:
			# TODO: Pick the best one
			var ore = overlapping_bodies[0]
			ore.hit()

# Called by an item to tell the player to pick it up
func pickup_item(item_stack):
	inventory.add_item(item_stack)


func swing_sword():
	get_node(sword_path).set_process(true)
	get_node(sword_path).swing()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		var overlapping_bodies = interaction_area.get_overlapping_bodies()
		if overlapping_bodies.size() > 0:
			# TODO: Pick the one closest to the middle maybe?
			var obj = overlapping_bodies[0]
			if obj.is_in_group('ore'):
				break_ore()
			elif obj.has_method('player_activate'):
				obj.player_activate(self)

	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		swing_sword()
