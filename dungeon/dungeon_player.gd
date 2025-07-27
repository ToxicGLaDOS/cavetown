extends AnimatedSprite2D

@export var animated_sprite_path: NodePath
# TODO: This is just for testing
@export var generator: DungeonGenerator

@onready var ray = $RayCast2D

enum Direction {UP, LEFT, DOWN, RIGHT}

var animated_sprite: AnimatedSprite2D
var tile_size: int = 32

func _ready():
	animated_sprite = get_node(animated_sprite_path)

func _input(event):

	# Make sure that we only move ourselves

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			ray.target_position = Vector2i.UP * tile_size
			ray.force_raycast_update()
			rotate_character(Direction.UP)
			if !ray.is_colliding():
				position.y -= tile_size

		if event.keycode == KEY_A:
			ray.target_position = Vector2i.LEFT * tile_size
			ray.force_raycast_update()
			rotate_character(Direction.LEFT)
			if !ray.is_colliding():
				position.x -= tile_size

		if event.keycode == KEY_S:
			ray.target_position = Vector2i.DOWN * tile_size
			ray.force_raycast_update()
			rotate_character(Direction.DOWN)
			if !ray.is_colliding():
				position.y += tile_size

		if event.keycode == KEY_D:
			ray.target_position = Vector2i.RIGHT * tile_size
			ray.force_raycast_update()
			rotate_character(Direction.RIGHT)
			if !ray.is_colliding():
				position.x += tile_size

		if event.keycode == KEY_SPACE:
			generator.generate_dungeon()

func rotate_character(direction):
	if direction == Direction.UP:
		animated_sprite.animation = "up"
	elif direction == Direction.LEFT:
		animated_sprite.animation = "left"
	elif direction == Direction.DOWN:
		animated_sprite.animation = "down"
	elif direction == Direction.RIGHT:
		animated_sprite.animation = "right"
