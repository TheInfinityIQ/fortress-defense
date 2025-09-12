extends Node2D

@onready var pawns: Node2D = $Pawns
@onready var aiPawn: CharacterBody2D = $Pawns/Unit
@onready var characterPawn: CharacterBody2D = $Pawns/Character

func _ready() -> void:
	characterPawn.followers.append(aiPawn)
