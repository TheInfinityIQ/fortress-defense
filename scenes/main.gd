# In your Town node or GameMaster - wherever you manage the overall game state

extends Node

@onready var terrain_layer: TileMapLayer = $"Town/Terrain"  # Adjust path as needed
@onready var pawn_nodes: Array[Node] = $"GameMaster/Pawns".get_children()       # Adjust path as needed

func _ready() -> void:
	terrain_layer.set_trackable_pawns(pawn_nodes)
