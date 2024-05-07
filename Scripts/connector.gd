extends Node2D

@onready var area_right = $PortalRight/Area2D
@onready var area_left = $PortalLeft/Area2D

func _on_area_right_2d_body_entered(body):
	if body.velocity.x > 0:
		body.position.x = area_left.global_position.x

func _on_area_right_2d_body_exited(body):
	pass # Replace with function body.

func _on_area_left_2d_body_entered(body):
	if body.velocity.x < 0:
		body.position.x = area_right.global_position.x

func _on_area_left_2d_body_exited(body):
	pass # Replace with function body.
