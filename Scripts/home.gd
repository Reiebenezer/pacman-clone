extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/survival.tscn")
	Globals.is_survival = true
	print("Survival Mode!")
