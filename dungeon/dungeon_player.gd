extends AnimatedSprite2D

@export var animated_sprite_path: NodePath
# TODO: This is just for testing
@export var generator: DungeonGenerator

enum Direction {UP, LEFT, DOWN, RIGHT}

var animated_sprite: AnimatedSprite2D
var tile_size: int = 16

func _ready():
	animated_sprite = get_node(animated_sprite_path)

func _input(event):
	# Make sure that we only move ourselves

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			position.y -= tile_size
			rotate_character(Direction.UP)

		if event.keycode == KEY_A:
			position.x -= tile_size
			rotate_character(Direction.LEFT)

		if event.keycode == KEY_S:
			position.y += tile_size
			rotate_character(Direction.DOWN)

		if event.keycode == KEY_D:
			position.x += tile_size
			rotate_character(Direction.RIGHT)

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

