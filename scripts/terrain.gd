extends TileMapLayer

@onready var _obstacles: TileMapLayer = $"../Obstacles"
var tile_states: Dictionary
var pawn_positions: Dictionary
var trackable_pawns: Array[Node]

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Check for static obstacles
	if _obstacles.get_cell_tile_data(coords):
		return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)

func set_trackable_pawns(pawns: Array[Node]) -> void:
	trackable_pawns = pawns

func _physics_process(delta: float) -> void:
	
	update_navigation_layer()
	pass

func update_navigation_layer() -> void:
	for tile in tile_states:
		if not pawn_positions.has(tile.key):
			get_cell_tile_data(tile.key).set_navigation_polygon(0, tile.value)
			tile_states.erase(tile.key)
	
	update_pawn_positions()

func update_pawn_positions() -> void:
	var coords: Vector2i
	for pawn in trackable_pawns:
		coords = local_to_map(pawn.global_position)
		pawn_positions.set(coords, pawn)
		
		get_cell_tile_data(coords).set_navigation_polygon(0, null)

func update_tile_states() -> void:
	var coords: Vector2i
	for pawn in trackable_pawns:
		coords = local_to_map(pawn.global_position)
		tile_states.set(coords, get_cell_tile_data(coords).get_navigation_polygon(0))

func set_tile_state(coords: Vector2i, nav_pol: NavigationPolygon) -> void:
	tile_states.set(coords, nav_pol)

func set_pawn_positions() -> void:
	pass
