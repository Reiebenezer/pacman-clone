extends Node

@onready var smallPellet = preload("res://Scenes/pellet_small.tscn")
@onready var largePellet = preload("res://Scenes/pellet_large.tscn")

@onready var game = $".." as Game
@export var ghosts: Array[Ghost]

var large_pellet_locations = [
	Vector2i(-17, -13),
	Vector2i( 16, -13),
	#Vector2i( -2, -17),
	#Vector2i(  1, -17),
	#Vector2i(-17,  -1),
	#Vector2i( 16,  -1),
	Vector2i(-17,   8),
	Vector2i( 16,   8),
]

func spawn_pellet(cell: Vector2i):
	var pellet
	game.total_pellets += 1
		
	if large_pellet_locations.has(cell):
		pellet = largePellet.instantiate() as Pellet
		pellet.allow_eating_ghosts = true
	else:
		pellet = smallPellet.instantiate() as Pellet
		pellet.allow_eating_ghosts = false
		
	pellet.global_position = (Vector2(cell) + Vector2(0.5, 1)) * 16
	pellet.pellet_eaten.connect(on_pellet_eaten)
	add_child(pellet)
			
func on_pellet_eaten(allow_eating_ghosts: bool):
	game.score_pellet()

	if allow_eating_ghosts:
		game.reset_ghost_increment()
		
		for ghost in ghosts:
			ghost.frighten()
