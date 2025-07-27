@tool
extends Node2D

class_name DungeonGenerator

@export var floor_tiles: TileMapLayer

# Bounds on the tilemap inclusive
@export var dungeon_min_bounds: Vector2i:
	set(value):
		dungeon_min_bounds = value
		update_configuration_warnings()
@export var dungeon_max_bounds: Vector2i:
	set(value):
		dungeon_max_bounds = value
		update_configuration_warnings()
@export var room_min_size: int:
	set(value):
		room_min_size = value
		update_configuration_warnings()
@export var room_max_size: int
@export var num_rooms: int
@export var max_attempts_per_room: int

var floor_atlas_position = Vector2i(5, 16)
var wall_atlas_position = Vector2i(4, 4)
var tile_source_id = 1
var rooms: Array[Room] = []
var astar_grid = AStarGrid2D.new()

func _get_configuration_warnings():
	var dungeon_size = dungeon_max_bounds - dungeon_min_bounds
	if room_min_size > dungeon_size.x or room_min_size > dungeon_size.y:
		return ["Bad room_min_size. room_min_size > dungeon size"]
	else:
		return []

func check_free_space(pos: Vector2i, size: Vector2i):
	for x in range(size.x):
		for y in range(size.y):
			if floor_tiles.get_cell_tile_data(Vector2i(pos.x + x, pos.y + y)) != null:
				return false

	return true

func generate_room() -> bool:
	for i in range(max_attempts_per_room):
		var room_size = dungeon_max_bounds - dungeon_min_bounds + Vector2i(1, 1)
		while room_size.x > dungeon_max_bounds.x - dungeon_min_bounds.x or room_size.y > dungeon_max_bounds.y - dungeon_min_bounds.y:
			room_size = Vector2i(randi_range(room_min_size, room_max_size), randi_range(room_min_size, room_max_size))

		var max_pos = dungeon_max_bounds - (room_size - Vector2i(1, 1))

		var room_x = randi_range(dungeon_min_bounds.x, max_pos.x)
		var room_y = randi_range(dungeon_min_bounds.y, max_pos.y)

		#print("Pos: (%s, %s), Size: (%s, %s)" % [room_x, room_y, room_size.x, room_size.y])	

		if !check_free_space(Vector2i(room_x, room_y), room_size):
			# We don't want to generate over an existing room
			# So this room failed and we try again
			continue

		rooms.append(Room.new(Vector2i(room_x, room_y), room_size))
		astar_grid.fill_solid_region(Rect2i(room_x, room_y, room_size.x, room_size.y))
		# Build floor
		for x in range(room_size.x):
			for y in range(room_size.y):
				floor_tiles.set_cell(Vector2i(room_x + x, room_y + y), tile_source_id, floor_atlas_position)

		# Build walls
		for x in range(room_size.x):
			floor_tiles.set_cell(Vector2i(room_x + x, room_y), tile_source_id, wall_atlas_position)
			floor_tiles.set_cell(Vector2i(room_x + x, room_y + room_size.y - 1), tile_source_id, wall_atlas_position)

		for y in range(room_size.y):
			floor_tiles.set_cell(Vector2i(room_x, room_y + y), tile_source_id, wall_atlas_position)
			floor_tiles.set_cell(Vector2i(room_x + room_size.x - 1, room_y + y), tile_source_id, wall_atlas_position)

		return true
	return false


func generate_rooms(num: int) -> bool:
	for i in range(num):
		if !generate_room():
			return false
	return true

func generate_bounds():
	var dungeon_size = dungeon_max_bounds - dungeon_min_bounds + Vector2i(1, 1)
	for x in range(dungeon_size.x):
		floor_tiles.set_cell(Vector2i(dungeon_min_bounds.x + x, dungeon_min_bounds.y), tile_source_id, wall_atlas_position)
		floor_tiles.set_cell(Vector2i(dungeon_min_bounds.x + x, dungeon_min_bounds.y + dungeon_size.y - 1), tile_source_id, wall_atlas_position)

	for y in range(dungeon_size.y):
		floor_tiles.set_cell(Vector2i(dungeon_min_bounds.x, dungeon_min_bounds.y + y), tile_source_id, wall_atlas_position)
		floor_tiles.set_cell(Vector2i(dungeon_min_bounds.x + dungeon_size.x - 1, dungeon_min_bounds.y + y), tile_source_id, wall_atlas_position)

func generate_dungeon():
	var dungeon_size = dungeon_max_bounds - dungeon_min_bounds + Vector2i(1, 1)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = Vector2(32, 32)
	
	var attempts = 0
	while true:
		attempts += 1
		rooms = []
		astar_grid.clear()
		astar_grid.region = Rect2i(dungeon_min_bounds.x, dungeon_min_bounds.y, dungeon_size.x, dungeon_size.y)
		astar_grid.update()
		floor_tiles.clear()
		if !generate_rooms(num_rooms):
			continue
		generate_bounds()
		print("Success after %s attempts" % attempts)
		break

	if len(rooms) > 1:
		for index in range(len(rooms)):
			var room = rooms[index]
			if !room.connected:
				if index == 0:
					# Set first room to connected to start the chain of connections
					room.connected = true
					continue
				var other_rooms = rooms.duplicate()
				# Filter out unconnected rooms so we only connect to
				# already connected rooms. Ensuring a fully connected
				# graph of rooms
				other_rooms = other_rooms.filter(func (r):
					return r.connected
				)

				var path = []
				var other_room: Room = other_rooms.pick_random()
				while path == []:
					var start = room.get_border_tile()
					var end = other_room.get_border_tile()
					astar_grid.set_point_solid(end, false)
					path = astar_grid.get_id_path(start, end)
					astar_grid.set_point_solid(end)

				# Set room to connected
				room.connected = true

				# Draw the path
				for point in path:
					floor_tiles.set_cell(point, tile_source_id, floor_atlas_position)
