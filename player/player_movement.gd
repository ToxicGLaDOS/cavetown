extends KinematicBody2D

export(float) var speed

# comment
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_key_pressed(KEY_W):
        move_and_slide(Vector2(0, -1) * speed * delta)
    if Input.is_key_pressed(KEY_A):
        move_and_slide(Vector2(-1, 0) * speed * delta)
    if Input.is_key_pressed(KEY_S):
        move_and_slide(Vector2(0, 1) * speed * delta)
    if Input.is_key_pressed(KEY_D):
        move_and_slide(Vector2(1, 0) * speed * delta)

