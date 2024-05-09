extends TileMap
class_name MazeTileMap

@onready var pellets = $"../Pellets"

var empty_cells = []
var spawnable_cells = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for cell in get_used_cells(0):
		if get_cell_tile_data(0, cell).get_custom_data("isEmpty"):
			empty_cells.push_front(cell)
		
			if get_cell_tile_data(0, cell).get_custom_data("isSpawnable"):
				pellets.spawn_pellet(cell)
				spawnable_cells.push_front(cell)
		
func get_random_empty_cell():
	return to_global(map_to_local(empty_cells.pick_random()))
	
func get_random_spawnable_cell():
	return to_global(map_to_local(spawnable_cells.pick_random()))
