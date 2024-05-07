extends Area2D
class_name Pellet

signal pellet_eaten(allow_eating_ghosts: bool)

@export var allow_eating_ghosts = false

func _on_body_entered(_body):
	pellet_eaten.emit(allow_eating_ghosts)
	queue_free()
