extends Node2D

@onready var ai_test_pawn: CharacterBody2D = $Pawns/Unit
@onready var player_pawn: CharacterBody2D = $Pawns/Character

var player_selectable_pawns: Array = []
var player_selected_pawns: Array = []

func _ready() -> void:
	player_selectable_pawns.append(ai_test_pawn)
	
	var followers: Array[CharacterBody2D] = []
	followers.append(ai_test_pawn)
	player_pawn.assign_followers(followers)

func clear_player_selected_pawns() -> void:
	for pawn in player_selected_pawns:
		pawn.deselect()
	
	player_selected_pawns = []

func add_player_selected_pawn(pawn) -> void:
	pawn.select()
	player_selected_pawns.append(pawn)
