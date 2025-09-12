extends TileMapLayer

@onready var _obstacles: TileMapLayer = $"../obstacles"
@onready var _bridges: TileMapLayer = $"../Bridges"

const TERRAIN_TILESET_ID = 3
const OBSTACLES_TILESET_ID = 6
const BRIDGES_TILESET_ID = 1

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in _obstacles.get_used_cells_by_id(OBSTACLES_TILESET_ID):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in _obstacles.get_used_cells_by_id(OBSTACLES_TILESET_ID):
		print("here")
		tile_data.set_navigation_polygon(TERRAIN_TILESET_ID, null)
	
	#if coords in _bridges.get_used_cells_by_id(BRIDGES_TILESET_ID):
		#var nav_polygon: NavigationPolygon = NavigationPolygon.new()
		#nav_polygon.
		#tile_data.set_navigation_polygon(BRIDGES_TILESET_ID, nav_polygon)
