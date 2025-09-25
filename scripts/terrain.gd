extends TileMapLayer

@onready var _obstacles: TileMapLayer = $"../Obstacles"

func _ready() -> void:
	notify_runtime_tile_data_update()

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _obstacles.get_cell_tile_data(coords) != null

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if _obstacles.get_cell_tile_data(coords):
		tile_data.set_navigation_polygon(0, null)
