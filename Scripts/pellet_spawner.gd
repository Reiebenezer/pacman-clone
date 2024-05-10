extends Node
class_name PelletSpawner

@onready var smallPellet = preload("res://Scenes/pellet_small.tscn")
@onready var largePellet = preload("res://Scenes/pellet_large.tscn")
@onready var tile_map = %TileMap

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

func spawn_pellet(cell: Vector2i, large: bool = false):
	var pellet
	game.total_pellets += 1
		
	if large_pellet_locations.has(cell) or large:
		pellet = largePellet.instantiate() as Pellet
		pellet.allow_eating_ghosts = true
	else:
		pellet = smallPellet.instantiate() as Pellet
		pellet.allow_eating_ghosts = false
		
	pellet.global_position = (Vector2(cell) + Vector2(0.5, 1)) * 16
	pellet.pellet_eaten.connect(on_pellet_eaten)
	add_child(pellet)

@onready var chomp_sound = $"../Sounds/Chomp"
func on_pellet_eaten(allow_eating_ghosts: bool):
	game.score_pellet()

	if allow_eating_ghosts:
		game.reset_ghost_increment()
		
		for ghost in ghosts:
			ghost.frighten()
			
	elif not chomp_sound.playing:
			chomp_sound.play()
			
	if Globals.is_survival:
		tile_map.spawn_random_power_pellet()
