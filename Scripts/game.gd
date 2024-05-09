extends Node2D
class_name Game

var score = 0

var pellets_eaten = 0
var total_pellets = 0

var ghosts_eaten = 0

const pellet_score_increment = 20
var ghost_score_increment = 200

@onready var pellets_eaten_display: Label = $CanvasLayer/pellets_eaten
@onready var score_display: Label = $CanvasLayer/score

@onready var game_over_screen = $CanvasLayer/GameOverScreen as ColorRect
@onready var end_text = $CanvasLayer/GameOverScreen/game_over as Label
@onready var result = $CanvasLayer/GameOverScreen/result as Label

func _ready():
	pellets_eaten_display.text = "Pellets Eaten: 0"
	score_display.text = "Score: 0"
	
	game_over_screen.hide()
	
func score_pellet():
	pellets_eaten += 1
	score += pellet_score_increment
	pellets_eaten_display.text = "Pellets Eaten: " + str(pellets_eaten)
	
	update_score()

func score_ghost():
	ghosts_eaten += 1
	score += ghost_score_increment
	
	ghost_score_increment *= 2
	update_score()
	
func reset_ghost_increment():
	ghost_score_increment = 200
	
func update_score():
	score_display.text = "Score: " + str(score)
	
	if pellets_eaten == total_pellets:
		print("Game Completed!")
		end(true)

func end(completed: bool):
	game_over_screen.show()
	result.text = "Total Score: " + str(score)
	
	if completed:
		end_text.text = "You Won!"
		
		get_tree().paused = true

func _on_button_pressed():
	get_tree().paused = false	
	get_tree().reload_current_scene()
