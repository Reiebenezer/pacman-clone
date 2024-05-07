extends Node

const cell_size = 16

@onready var tilemap = %TileMap
@onready var cells = tilemap.get_used_cells_by_id(0, 0, Vector2i(2, 1))
@onready var unspawnable_cells = tilemap.get_used_cells_by_id(0, 0, Vector2i(2, 1), 18)
@onready var unspawnable_cells2 = tilemap.get_used_cells_by_id(0, 0, Vector2i(2, 1), 19)

@onready var smallPellet = preload("res://Scenes/pellet_small.tscn")
@onready var largePellet = preload("res://Scenes/pellet_large.tscn")

@export var ghosts: Array[Ghost]

var large_pellet_locations = [
	Vector2i(-17, -13),
	Vector2i( 16, -13),
	Vector2i( -2, -17),
	Vector2i(  1, -17),
	Vector2i(-17,  -1),
	Vector2i( 16,  -1),
	Vector2i(-17,   8),
	Vector2i( 16,   8),
]

func _ready():
	Manager.total_pellets = len(cells)
	
	for cell in cells:
		if not unspawnable_cells.has(cell) and not unspawnable_cells2.has(cell):
			var pellet
			
			if large_pellet_locations.has(cell):
				pellet = largePellet.instantiate() as Pellet
				pellet.allow_eating_ghosts = true
			else:
				pellet = smallPellet.instantiate() as Pellet
				pellet.allow_eating_ghosts = false
				
			pellet.global_position = (Vector2(cell) + Vector2(0.5, 1)) * cell_size
			pellet.pellet_eaten.connect(on_pellet_eaten)
			add_child(pellet)
			
func on_pellet_eaten(allow_eating_ghosts: bool):
	Manager.score_pellet()
	
	if allow_eating_ghosts:
		for ghost in ghosts:
			ghost.frighten()
