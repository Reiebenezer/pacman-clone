extends CharacterBody2D
class_name Player

var direction = Vector2.ZERO
var next_direction = Vector2.ZERO

var shape_query = PhysicsShapeQueryParameters2D.new()

@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var game = $".."

@export var SPEED = 150
var dead: bool = false

func _ready():
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2

func _physics_process(delta):
	if Input.is_action_pressed("right"):
		next_direction = Vector2.RIGHT
		
	elif Input.is_action_pressed("left"):
		next_direction = Vector2.LEFT		
		
	elif Input.is_action_pressed("up"):
		next_direction = Vector2.UP		
		
	elif Input.is_action_pressed("down"):
		next_direction = Vector2.DOWN		
	
	handle_direction(next_direction, delta)
	
	velocity = direction * SPEED
	move_and_slide()
	
func handle_direction(next_dir: Vector2, delta: float):
	shape_query.transform = global_transform.translated(next_dir * SPEED * delta * 2)
	
	# If the next direction does not intersect with any object
	if (direction == Vector2.ZERO):
		direction = next_direction
		
	var query = get_world_2d().direct_space_state.intersect_shape(shape_query)
	if query.size() == 0:
		direction = next_direction
		
	if direction == Vector2.RIGHT:
		rotation_degrees = 0
		
	elif direction == Vector2.LEFT:
		rotation_degrees = 180
		
	elif direction == Vector2.DOWN:
		rotation_degrees = 90
		
	elif direction == Vector2.UP:
		rotation_degrees = 270
		
		
func died():
	dead = true	
	SPEED = 0
	
	animated_sprite_2d.play("dead")
	animated_sprite_2d.animation_finished.connect(death_animation_finished)
	
	print("Player Died")

func death_animation_finished():
	print("Death Animation Complete")
	set_physics_process(false)
	set_collision_mask_value(1, false)
	
	game.end(false)
