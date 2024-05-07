extends Node

var score = 0

var pellets_eaten = 0
var total_pellets = 0

var ghosts_eaten = 0

const pellet_score_increment = 20
var ghost_score_increment = 200

@onready var pellets_eaten_display: Label = $/root/Game/CanvasLayer/pellets_eaten
@onready var score_display: Label = $/root/Game/CanvasLayer/score

func score_pellet():
	pellets_eaten += 1
	score += pellet_score_increment
	pellets_eaten_display.text = "Pellets Eaten: " + str(pellets_eaten)
	
	update_score()

func score_ghost():
	ghosts_eaten += 1
	score += ghost_score_increment
	
	ghost_score_increment *= 2
	
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	
	get_tree().paused = false
	update_score()
	
func reset_ghost_increment():
	ghost_score_increment = 200
	
func update_score():
	score_display.text = "Score: " + str(score)
	
	if pellets_eaten == total_pellets:
		print("Game Completed!")
