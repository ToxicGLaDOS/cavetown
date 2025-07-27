class_name Room

var position: Vector2i
var size: Vector2i

var connected = false

func _init(_position, _size) -> void:
	position = _position
	size = _size

func get_border_tile() -> Vector2i:
	var options = []
	# 1, x-1 because we don't want corners
	for x in range(1, size.x - 1):
		options.append(Vector2i(position.x + x, position.y))
		options.append(Vector2i(position.x + x, position.y + size.y - 1))
	
	for y in range(1, size.y - 1):
		options.append(Vector2i(position.x, position.y + y))
		options.append(Vector2i(position.x + size.x - 1, position.y + y))

	return options.pick_random()
