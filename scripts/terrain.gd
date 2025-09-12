extends TileMapLayer

@onready var _obsticles: TileMapLayer = $"../Obsticles"
@onready var _bridges: TileMapLayer = $"../Bridges"

const OBSTICLES_TILESET_ID = 6
const BRIDGES_TILESET_ID = 1

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in _obsticles.get_used_cells_by_id(OBSTICLES_TILESET_ID):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in _obsticles.get_used_cells_by_id(OBSTICLES_TILESET_ID):
		tile_data.set_navigation_polygon(OBSTICLES_TILESET_ID, null)
	
	if coords in _bridges.get_used_cells_by_id(BRIDGES_TILESET_ID):
		tile_data.set_navigation_polygon(BRIDGES_TILESET_ID, null)
