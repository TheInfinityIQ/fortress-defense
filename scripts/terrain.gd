extends TileMapLayer

@onready var _obstacles: TileMapLayer = $"../Obstacles"

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if _obstacles.get_cell_tile_data(coords):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
