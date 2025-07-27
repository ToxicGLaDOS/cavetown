extends Node2D

class_name MiniMap

@onready var minimap_tiles = $TileMapLayer

var tile_source = 0
var player_atlas_pos = Vector2i(5, 2)

func create_minimap(tile_map: TileMapLayer, wall_atlas_pos: Vector2i):
	var used_rect = tile_map.get_used_rect()

	for x in range(used_rect.size.x):
		for y in range(used_rect.size.y):
			var tile_pos = Vector2i(used_rect.position.x + x, used_rect.position.y + y)
			var atlas_pos = tile_map.get_cell_atlas_coords(tile_pos)

			if atlas_pos == wall_atlas_pos:
				minimap_tiles.set_cell(tile_pos, tile_source, wall_atlas_pos)

func clear_minimap():
	minimap_tiles.clear()

# TODO: Maybe minimap should have a persistent reference to the
# dungeon tiles so it can update this without a reference to
# the previous position to know what to delete.
#
# That would also make it possible to redraw the whole minimap
# every move, which may be expensive, but also easier?
func set_player_position(old_pos: Vector2i, new_pos: Vector2i):
	minimap_tiles.set_cell(old_pos, tile_source, Vector2i(-1, -1))
	minimap_tiles.set_cell(new_pos, tile_source, player_atlas_pos)
